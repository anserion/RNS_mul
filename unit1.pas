//Copyright 2020 Andrey S. Ionisyan (anserion@gmail.com)
//
//Licensed under the Apache License, Version 2.0 (the "License");
//you may not use this file except in compliance with the License.
//You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
//Unless required by applicable law or agreed to in writing, software
//distributed under the License is distributed on an "AS IS" BASIS,
//WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//See the License for the specific language governing permissions and
//limitations under the License.

unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, Grids, StdCtrls;

type

  { TForm1 }

  TForm1 = class(TForm)
    BTN_P_set: TButton;
    BTN_calc: TButton;
    Edit_op2: TEdit;
    Edit_res: TEdit;
    Edit_op1: TEdit;
    Label1: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label9: TLabel;
    Label_P: TLabel;
    Label8: TLabel;
    SG_P: TStringGrid;
    SG_RNS_mul: TStringGrid;
    SG_ROM_digits: TStringGrid;
    SG_RNS_op2: TStringGrid;
    SG_RNS_op1: TStringGrid;
    SG_ortho_sum: TStringGrid;
    SG_ortho_read: TStringGrid;
    SG_ROM_Ortho: TStringGrid;
    procedure BTN_P_setClick(Sender: TObject);
    procedure BTN_calcClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    procedure ROM_ortho_calc;
    procedure ROM_digits_calc;
    procedure ROM_mul_calc;
    procedure Op1_to_RNS_calc;
    procedure Op2_to_RNS_calc;
    procedure RNS_mul_calc;
    procedure ROM_ortho_read;
    procedure ortho_summ;
  public

  end;

const max_p=1023;

var
  Form1: TForm1;

  P:array[1..8]of integer;
  PP:LongInt;
  op1_dec,op2_dec,res_dec:integer;
  ROM_mul:array[1..8,0..max_p-1,0..max_p-1]of integer;
  ROM_ortho:array[1..8,0..max_p]of integer;
  ROM_digits:array[1..8,0..200]of integer;
  op1_RNS:array[1..8]of integer;
  op2_RNS:array[1..8]of integer;
  mul_RNS:array[1..8]of integer;

  summ:array[0..3,1..8]of integer;
  corr:array[1..3,1..8]of integer;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.ROM_mul_calc;
var k,i,j:integer;
begin
  for k:=1 to 8 do
    for i:=0 to P[k]-1 do
      for j:=0 to P[k]-1 do
        ROM_mul[k,i,j]:=(i*j) mod P[k];
end;

procedure TForm1.ROM_ortho_calc;
var i,k,max_p,tmp_pp,basis:integer;
begin
  max_p:=P[1];
  for k:=1 to 8 do
    if max_p<P[k] then max_p:=P[k];

  for k:=1 to 8 do
  begin
    ROM_ortho[k,0]:=0;
    tmp_pp:=1; basis:=0;
    for i:=1 to 8 do if i<>k then tmp_pp:=tmp_pp*P[i];
    for i:=1 to P[k]-1 do if ((tmp_pp*i) mod P[k])=1 then basis:=tmp_pp*i;
    for i:=1 to P[k]-1 do ROM_ortho[k,i]:=(basis*i) mod PP;
  end;
end;

procedure TForm1.ROM_digits_calc;
var i,j,k,tmp:integer;
begin
  for k:=1 to 8 do
  begin
    tmp:=1; ROM_digits[k,0]:=0;
    for i:=0 to 8 do
    begin
      for j:=1 to 10 do ROM_digits[k,i*9+j]:=(tmp*j)mod P[k];
      tmp:=tmp*10;
    end;
  end;
end;

procedure TForm1.Op1_to_RNS_calc;
var k,i,tmp,tmp_pow,digit,digits_num:integer;
begin
  tmp:=op1_dec;
  if tmp=0 then digits_num:=1 else digits_num:=0;
  while tmp>0 do begin tmp:=tmp div 10; digits_num:=digits_num+1; end;
  SG_RNS_op1.RowCount:=digits_num+2;

  tmp:=op1_dec; tmp_pow:=1;
  for k:=1 to 8 do op1_RNS[k]:=0;
  for i:=0 to digits_num-1 do
  begin
    digit:=tmp mod 10;
    SG_RNS_op1.Cells[0,digits_num-i]:=IntToStr(digit*tmp_pow);
    if digit<>0 then
    for k:=1 to 8 do
    begin
      SG_RNS_op1.Cells[k,digits_num-i]:=IntToStr(ROM_digits[k,digit+i*9]);
      op1_RNS[k]:=op1_RNS[k]+ROM_digits[k,digit+i*9];
      if op1_RNS[k]>=P[k] then op1_RNS[k]:=op1_RNS[k]-P[k];
    end
    else for k:=1 to 8 do SG_RNS_op1.Cells[k,digits_num-i]:='0';
    tmp:=tmp div 10; tmp_pow:=tmp_pow*10;
  end;

  SG_RNS_op1.Cells[0,digits_num+1]:='Сумма';
  for k:=1 to 8 do SG_RNS_op1.Cells[k,digits_num+1]:=IntToStr(op1_RNS[k]);
end;

procedure TForm1.Op2_to_RNS_calc;
var k,i,tmp,tmp_pow,digit,digits_num:integer;
begin
  tmp:=op2_dec;
  if tmp=0 then digits_num:=1 else digits_num:=0;
  while tmp>0 do begin tmp:=tmp div 10; digits_num:=digits_num+1; end;
  SG_RNS_op2.RowCount:=digits_num+2;

  tmp:=op2_dec; tmp_pow:=1;
  for k:=1 to 8 do op2_RNS[k]:=0;
  for i:=0 to digits_num-1 do
  begin
    digit:=tmp mod 10;
    SG_RNS_op2.Cells[0,digits_num-i]:=IntToStr(digit*tmp_pow);
    if digit<>0 then
    for k:=1 to 8 do
    begin
      SG_RNS_op2.Cells[k,digits_num-i]:=IntToStr(ROM_digits[k,digit+i*9]);
      op2_RNS[k]:=op2_RNS[k]+ROM_digits[k,digit+i*9];
      if op2_RNS[k]>=P[k] then op2_RNS[k]:=op2_RNS[k]-P[k];
    end
    else for k:=1 to 8 do SG_RNS_op2.Cells[k,digits_num-i]:='0';
    tmp:=tmp div 10; tmp_pow:=tmp_pow*10;
  end;

  SG_RNS_op2.Cells[0,digits_num+1]:='Сумма';
  for k:=1 to 8 do SG_RNS_op2.Cells[k,digits_num+1]:=IntToStr(op2_RNS[k]);
end;

procedure TForm1.RNS_mul_calc;
var k:integer;
begin
  for k:=1 to 8 do
    mul_RNS[k]:=ROM_mul[k,op1_RNS[k],op2_RNS[k]];
  //mul_RNS[k]:=(op1_RNS[k]*op2_RNS[k])mod P[k];
end;

procedure TForm1.ROM_ortho_read;
var k:integer;
begin
  for k:=1 to 8 do summ[0,k]:=ROM_ortho[k,mul_RNS[k]];
end;

procedure TForm1.ortho_summ;
begin
  summ[1,1]:=summ[0,1]+summ[0,2]; if summ[1,1]<PP then corr[1,1]:=summ[1,1] else corr[1,1]:=summ[1,1]-pp;
  summ[1,2]:=summ[0,3]+summ[0,4]; if summ[1,2]<PP then corr[1,2]:=summ[1,2] else corr[1,2]:=summ[1,2]-pp;
  summ[1,3]:=summ[0,5]+summ[0,6]; if summ[1,3]<PP then corr[1,3]:=summ[1,3] else corr[1,3]:=summ[1,3]-pp;
  summ[1,4]:=summ[0,7]+summ[0,8]; if summ[1,4]<PP then corr[1,4]:=summ[1,4] else corr[1,4]:=summ[1,4]-pp;
  summ[2,1]:=corr[1,1]+corr[1,2]; if summ[2,1]<PP then corr[2,1]:=summ[2,1] else corr[2,1]:=summ[2,1]-pp;
  summ[2,2]:=corr[1,3]+corr[1,4]; if summ[2,2]<PP then corr[2,2]:=summ[2,2] else corr[2,2]:=summ[2,2]-pp;
  summ[3,1]:=corr[2,1]+corr[2,2]; if summ[3,1]<PP then corr[3,1]:=summ[3,1] else corr[3,1]:=summ[3,1]-pp;
  res_dec:=corr[3,1];
end;

procedure TForm1.BTN_calcClick(Sender: TObject);
var k:integer;
begin
  op1_dec:=StrToInt(Edit_op1.text);
  if op1_dec<0 then op1_dec:=0;
  if op1_dec>100000000 then op1_dec:=100000000;
  Edit_op1.text:=IntToStr(op1_dec);

  op2_dec:=StrToInt(Edit_op2.text);
  if op2_dec<0 then op2_dec:=0;
  if op2_dec>100000000 then op2_dec:=100000000;
  Edit_op2.text:=IntToStr(op2_dec);

  op1_to_RNS_calc;
  op2_to_RNS_calc;
  RNS_mul_calc;
  ROM_ortho_read;
  ortho_summ;

  for k:=1 to 8 do SG_RNS_mul.Cells[k,1]:=IntToStr(op1_RNS[k]);
  for k:=1 to 8 do SG_RNS_mul.Cells[k,2]:=IntToStr(op2_RNS[k]);
  for k:=1 to 8 do SG_RNS_mul.Cells[k,3]:=IntToStr(mul_RNS[k]);

  for k:=1 to 8 do SG_ortho_read.Cells[k,0]:=IntToStr(summ[0,k]);

  for k:=1 to 4 do SG_ortho_sum.Cells[k,0]:=IntToStr(summ[1,k]);
  for k:=1 to 4 do SG_ortho_sum.Cells[k,1]:=IntToStr(corr[1,k]);
  for k:=1 to 2 do SG_ortho_sum.Cells[k,2]:=IntToStr(summ[2,k]);
  for k:=1 to 2 do SG_ortho_sum.Cells[k,3]:=IntToStr(corr[2,k]);
  SG_ortho_sum.Cells[1,4]:=IntToStr(summ[3,1]);
  SG_ortho_sum.Cells[1,5]:=IntToStr(corr[3,1]);

  Edit_res.text:=IntToStr(res_dec);
end;

procedure TForm1.BTN_P_setClick(Sender: TObject);
var k,i,tmp:integer;
begin
  for k:=1 to 8 do if not(TryStrToInt(SG_P.Cells[k,0],tmp)) then SG_P.Cells[k,0]:='1';
  for k:=1 to 8 do P[k]:=StrToInt(SG_P.Cells[k,0]);

  PP:=1; for k:=1 to 8 do PP:=PP*P[k];
  ROM_mul_calc;
  ROM_ortho_calc;
  ROM_digits_calc;

  Label_P.caption:='Диапазон СОК: '+IntToStr(PP);
  for k:=1 to 8 do SG_P.Cells[k,0]:=IntToStr(P[k]);
  for k:=1 to 8 do SG_RNS_op1.Cells[k,0]:='p'+IntToStr(k)+'='+IntToStr(P[k]);
  for k:=1 to 8 do SG_RNS_op2.Cells[k,0]:='p'+IntToStr(k)+'='+IntToStr(P[k]);
  for k:=1 to 8 do SG_RNS_mul.Cells[k,0]:='p'+IntToStr(k)+'='+IntToStr(P[k]);
  for k:=1 to 8 do SG_ROM_ortho.Cells[k,0]:='p'+IntToStr(k)+'='+IntToStr(P[k]);
  for k:=1 to 8 do SG_ROM_digits.Cells[k,0]:='p'+IntToStr(k)+'='+IntToStr(P[k]);

  SG_ROM_Ortho.RowCount:=max_p+1;
  for i:=0 to max_p-1 do SG_ROM_Ortho.Cells[0,i+1]:=IntToStr(i);
  for k:=1 to 8 do
    for i:=0 to max_p-1 do SG_ROM_Ortho.Cells[k,i+1]:='';

  for k:=1 to 8 do
    for i:=0 to P[k]-1 do
      SG_ROM_Ortho.Cells[k,i+1]:=IntToStr(ROM_ortho[k,i]);

  SG_ROM_digits.RowCount:=84;
  SG_ROM_digits.Cells[0,1]:=IntToStr(0);
  tmp:=1;
  for i:=0 to 8 do
  begin
    for k:=1 to 10 do SG_ROM_digits.Cells[0,i*9+k+1]:=IntToStr(tmp*k);
    tmp:=tmp*10;
  end;
  for k:=1 to 8 do
    for i:=0 to 82 do
      SG_ROM_digits.Cells[k,i+1]:=IntToStr(ROM_digits[k,i]);

end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  SG_P.Cells[0,0]:='основания';
  SG_P.Cells[1,0]:='2';
  SG_P.Cells[2,0]:='3';
  SG_P.Cells[3,0]:='5';
  SG_P.Cells[4,0]:='7';
  SG_P.Cells[5,0]:='11';
  SG_P.Cells[6,0]:='13';
  SG_P.Cells[7,0]:='17';
  SG_P.Cells[8,0]:='19';

  SG_RNS_op1.Cells[0,0]:='разряд';
  SG_RNS_op2.Cells[0,0]:='разряд';

  SG_RNS_mul.Cells[0,0]:='основания';
  SG_RNS_mul.Cells[0,1]:='оп_1 в СОК';
  SG_RNS_mul.Cells[0,2]:='оп_2 в СОК';
  SG_RNS_mul.Cells[0,3]:='Произведение';

  SG_ortho_read.Cells[0,0]:='извлечено';

  SG_ortho_sum.Cells[0,0]:='сумма';
  SG_ortho_sum.Cells[0,1]:='коррекция';
  SG_ortho_sum.Cells[0,2]:='сумма';
  SG_ortho_sum.Cells[0,3]:='коррекция';
  SG_ortho_sum.Cells[0,4]:='сумма';
  SG_ortho_sum.Cells[0,5]:='коррекция';

  SG_ROM_Ortho.Cells[0,0]:='цифра';
  SG_ROM_digits.Cells[0,0]:='число';

  BTN_P_setClick(self);
  BTN_CalcClick(self);
end;

end.


{ Just another Lase Show Editor (Jlse) (based on Heathcliff)

  Copyright (C) 1999,2000,2010 Patrick Michael Kolla.
                2013 Christian Ulrich (info@cu-tec.de)

  This source is free software; you can redistribute it and/or modify it under
  the terms of the GNU General Public License as published by the Free
  Software Foundation; either version 3 of the License, or (at your option)
  any later version.

  This code is distributed in the hope that it will be useful, but WITHOUT ANY
  WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
  FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
  details.

  A copy of the GNU General Public License is available on the World Wide Web
  at <http://www.gnu.org/copyleft/gpl.html>. You can also obtain it by writing
  to the Free Software Foundation, Inc., 59 Temple Place - Suite 330, Boston,
  MA 02111-1307, USA.
}

unit uDelays;

{$MODE Delphi}

interface

uses
  LCLIntf, LCLType, LMessages, Messages, SysUtils, Classes, Graphics,
  Controls, Forms, Dialogs,
  StdCtrls, Buttons;

type
  TFormDelays = class(TForm)
    bnCancel: TBitBtn;
    bnHelp: TBitBtn;
    bnOK: TBitBtn;
    editStep10: TEdit;
    editStep40: TEdit;
    editStep5: TEdit;
    editStepEdges: TEdit;
    groupSteps: TGroupBox;
    st10Degree: TStaticText;
    st40Degree: TStaticText;
    st5Degree: TStaticText;
    stMax: TStaticText;
  private
  public
    function Execute(var Step5, Step10, Step40, StepMax: word): boolean;
  end;

var
  FormDelays: TFormDelays;

implementation

{$R *.lfm}

{ TFormDelays }

function TFormDelays.Execute(var Step5, Step10, Step40, StepMax: word): boolean;
var
  sStep: string;
  i, iErrorCode: integer;
begin
  editStep5.Text := IntToStr(Step5);
  editStep10.Text := IntToStr(Step10);
  editStep40.Text := IntToStr(Step40);
  editStepEdges.Text := IntToStr(StepMax);
  Result := ShowModal = mrOk;
  if Result then
    begin
    sStep := editStep5.Text;
    Val(sStep, i, iErrorCode);
    if iErrorCode = 0 then
      Step5 := i;
    sStep := editStep10.Text;
    Val(sStep, i, iErrorCode);
    if iErrorCode = 0 then
      Step10 := i;
    sStep := editStep40.Text;
    Val(sStep, i, iErrorCode);
    if iErrorCode = 0 then
      Step40 := i;
    sStep := editStepEdges.Text;
    Val(sStep, i, iErrorCode);
    if iErrorCode = 0 then
      StepMax := i;

    end;
end;

end.

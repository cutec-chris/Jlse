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

unit uhelplines;

{$MODE Delphi}

interface

uses
  LCLIntf, LCLType, LMessages, Messages, SysUtils, Classes, Graphics,
  Controls, Forms, Dialogs,
  StdCtrls, Buttons, ComCtrls, uLaserFrames;

type
  TFormHelpLines = class(TForm)
    bnAdd2P: TBitBtn;
    bnAddX: TBitBtn;
    bnAddY: TBitBtn;
    bnCancel: TBitBtn;
    bnDel2P: TBitBtn;
    bnDelX: TBitBtn;
    bnDelY: TBitBtn;
    bnHelp: TBitBtn;
    bnOK: TBitBtn;
    bnUse: TBitBtn;
    editX: TEdit;
    editX1: TEdit;
    editX2: TEdit;
    editY: TEdit;
    editY1: TEdit;
    editY2: TEdit;
    lbX: TListBox;
    lbY: TListBox;
    lv2P: TListView;
    pcHelplines: TPageControl;
    stLineAtX: TStaticText;
    stLineAtY: TStaticText;
    st2Point1st: TStaticText;
    st2Point2nd: TStaticText;
    st2PointX: TStaticText;
    st2PointY: TStaticText;
    tsD: TTabSheet;
    tsX: TTabSheet;
    tsY: TTabSheet;
    procedure bnAdd2PClick(Sender: TObject);
    procedure bnAddXClick(Sender: TObject);
    procedure bnAddYClick(Sender: TObject);
    procedure bnDel2PClick(Sender: TObject);
    procedure bnDelXClick(Sender: TObject);
    procedure bnDelYClick(Sender: TObject);
    procedure bnUseClick(Sender: TObject);
    procedure lbXClick(Sender: TObject);
    procedure lbYClick(Sender: TObject);
    procedure lv2PClick(Sender: TObject);
  private
    FHelpLines: THelpLines;
    procedure ApplyNow;
  public
    function Execute(const HelpLines: THelpLines): boolean;
  end;

var
  FormHelpLines: TFormHelpLines;

implementation

uses
  uMain;

{$R *.lfm}

procedure TFormHelpLines.lbXClick(Sender: TObject);
begin
  if lbX.ItemIndex > -1 then
    editX.Text := lbX.Items[lbX.ItemIndex];
end;

procedure TFormHelpLines.bnAddXClick(Sender: TObject);
var
  sXText: string;
  i, iErrorCode: integer;
begin
  sXText := editX.Text;
  Val(sXText, i, iErrorCode);
  if iErrorCode = 0 then
    begin
    if lbX.Items.IndexOf(IntToStr(i)) < 01 then
      begin
      lbX.Items.Add(IntToStr(i));
      end;
    end
  else
    begin
    editX.Text := '';
    end;
end;

procedure TFormHelpLines.bnDelXClick(Sender: TObject);
begin
  if lbX.Items.IndexOf(editX.Text) > -1 then
    begin
    lbX.Items.Delete(lbX.Items.IndexOf(editX.Text));
    end;
end;

procedure TFormHelpLines.bnAddYClick(Sender: TObject);
var
  sYText: string;
  i, iErrorCode: integer;
begin
  sYText := editY.Text;
  Val(sYText, i, iErrorCode);
  if iErrorCode = 0 then
    begin
    if lbY.Items.IndexOf(IntToStr(i)) < 0 then
      begin
      lbY.Items.Add(IntToStr(i));
      end;
    end
  else
    begin
    editY.Text := '';
    end;
end;

procedure TFormHelpLines.bnDelYClick(Sender: TObject);
begin
  if lbY.Items.IndexOf(editY.Text) > -1 then
    begin
    lbY.Items.Delete(lbY.Items.IndexOf(editY.Text));
    end;
end;

procedure TFormHelpLines.lbYClick(Sender: TObject);
begin
  if lbY.ItemIndex > -1 then
    begin
    editY.Text := lbY.Items[lbY.ItemIndex];
    end;
end;

procedure TFormHelpLines.bnUseClick(Sender: TObject);
begin
  ApplyNow;
  FormMain.Redraw;
end;

function TFormHelpLines.Execute(const HelpLines: THelpLines): boolean;
var
  li: TListItem;
  iHelpLine: integer;
begin
  lbX.Items.Clear;
  FHelpLines := HelpLines;
  for iHelpLine := 0 to Pred(Length(HelpLines.x)) do
    lbX.Items.Add(IntToStr(HelpLines.x[iHelpLine]));
  lbY.Items.Clear;
  for iHelpLine := 0 to Pred(Length(HelpLines.y)) do
    lbY.Items.Add(IntToStr(HelpLines.y[iHelpLine]));
  lv2P.Items.Clear;
  for iHelpLine := 0 to Pred(Length(HelpLines.d[0])) do
    begin
    li := lv2P.Items.Add;
    li.Caption := IntToStr(HelpLines.d[0, iHelpLine].x);
    li.SubItems.Add(IntToStr(HelpLines.d[0, iHelpLine].y));
    li.SubItems.Add(IntToStr(HelpLines.d[1, iHelpLine].x));
    li.SubItems.Add(IntToStr(HelpLines.d[1, iHelpLine].y));
    end;
  Result := ShowModal = mrOk;
  if Result then
    begin
    ApplyNow;
    end;
end;

procedure TFormHelpLines.lv2PClick(Sender: TObject);
var
  li: TListItem;
begin
  if Assigned(lv2P.Selected) then
    begin
    li := lv2P.Selected;
    editX1.Text := li.Caption;
    editY1.Text := li.SubItems[0];
    editX2.Text := li.SubItems[1];
    editY2.Text := li.SubItems[2];
    end;
end;

procedure TFormHelpLines.ApplyNow;
var
  li: TListItem;
  iHelpLine, iCoordinate, iErrorCode: integer;
begin
  SetLength(FHelpLines.x, lbX.Items.Count);
  for iHelpLine := 0 to Pred(lbX.Items.Count) do
    begin
    Val(lbX.Items[iHelpLine], iCoordinate, iErrorCode);
    if iErrorCode <> 0 then
      iCoordinate := 0;
    FHelpLines.x[iHelpLine] := iCoordinate;
    end;
  SetLength(FHelpLines.y, lbY.Items.Count);
  for iHelpLine := 0 to lbY.Items.Count - 1 do
    begin
    Val(lbY.Items[iHelpLine], iCoordinate, iErrorCode);
    if iErrorCode <> 0 then
      iCoordinate := 0;
    FHelpLines.y[iHelpLine] := iCoordinate;
    end;
  SetLength(FHelpLines.d[0], lv2P.Items.Count);
  SetLength(FHelpLines.d[1], lv2P.Items.Count);
  for iHelpLine := 0 to lv2P.Items.Count - 1 do
    begin
    li := lv2P.Items[iHelpLine];
    Val(li.Caption, iCoordinate, iErrorCode);
    if iErrorCode <> 0 then
      iCoordinate := 0;
    FHelpLines.d[0, iHelpLine].x := iCoordinate;
    Val(li.subitems[0], iCoordinate, iErrorCode);
    if iErrorCode <> 0 then
      iCoordinate := 0;
    FHelpLines.d[0, iHelpLine].y := iCoordinate;
    Val(li.subitems[1], iCoordinate, iErrorCode);
    if iErrorCode <> 0 then
      iCoordinate := 0;
    FHelpLines.d[1, iHelpLine].x := iCoordinate;
    Val(li.subitems[2], iCoordinate, iErrorCode);
    if iErrorCode <> 0 then
      iCoordinate := 0;
    FHelpLines.d[1, iHelpLine].y := iCoordinate;
    end;
end;

procedure TFormHelpLines.bnAdd2PClick(Sender: TObject);
var
  li: TListItem;
begin
  li := lv2P.Items.Add;
  li.Caption := editX1.Text;
  li.SubItems.Add(editY1.Text);
  li.SubItems.Add(editX2.Text);
  li.SubItems.Add(editY2.Text);
end;

procedure TFormHelpLines.bnDel2PClick(Sender: TObject);
begin
  if Assigned(lv2P.Selected) then
    begin
    lv2P.Items.Delete(lv2P.Selected.Index);
    end;
end;

end.

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

unit uPreview;

{$MODE Delphi}

interface

uses
  LCLIntf, LCLType, LMessages, Messages, SysUtils, Classes, Graphics,
  Controls, Forms, Dialogs,
  ExtCtrls, ImgList, ComCtrls, ActnList, ToolWin;

type
  TFormPreview = class(TForm)
    aLoop: TAction;
    alPreview: TActionList;
    aPlay: TAction;
    aRewind: TAction;
    aStop: TAction;
    bnLoop: TToolButton;
    bnPlay: TToolButton;
    bnPreviewPos: TToolButton;
    bnRewind: TToolButton;
    bnSeparator1: TToolButton;
    bnSeparator2: TToolButton;
    ilPreview: TImageList;
    imgPreview: TImage;
    tbPreviewPos: TTrackBar;
    toolbarPreview: TToolBar;
    procedure aPlayExecute(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
  public
    DataStream: TMemoryStream;
  end;

var
  FormPreview: TFormPreview;

implementation

uses
  uMain;

{$R *.lfm}

procedure TFormPreview.aPlayExecute(Sender: TObject);
const
  CDisplayDuration = 200;
var
  lData: longint;
  bDataX, bDataY: byte;
  i, j: integer;
begin
  if Assigned(DataStream) then
    begin
    DataStream.Seek(40, soFromBeginning);
    Caption := 'Preview playing...';
    imgPreview.Canvas.Brush.Color := clBlack;
    imgPreview.Canvas.Brush.Style := bsSolid;
    imgPreview.Canvas.FillRect(Rect(0, 0, 256, 256));
    imgPreview.Canvas.Pen.Color := FormMain.MyColors[0, myc_norm];
    imgPreview.Canvas.MoveTo(128, 128);
    i := 0;
    j := 0;
    while DataStream.Position < DataStream.Size do
      begin
      DataStream.Read(lData, 4);
      bDataX := ((lData and $0000FF00) shr 8) - 128;
      bDataY := 128 - ((lData and $FF000000) shr 24);
      if (lData and 1) = 1 then
        begin
        imgPreview.Canvas.Pen.Color := FormMain.MyColors[1, myc_norm];
        end
      else
        begin
        imgPreview.Canvas.pen.color := FormMain.MyColors[0, myc_norm];
        end;
      if (lData and 2) = 0 then
        begin
        imgPreview.Canvas.LineTo(bDataX, bDataY);
        end
      else
        begin
        imgPreview.Canvas.MoveTo(bDataX, bDataY);
        end;
      //imgPreview.canvas.pixels[bx,by] := clRed;
      Inc(i);
      if (i mod CDisplayDuration) = 0 then
        begin
        Inc(j);
        if (j mod 10) = 0 then
          begin
          //imgPreview.canvas.FillRect(canvas.cliprect);
          imgPreview.canvas.FillRect(Rect(0, 0, 256, 256));
          tbPreviewPos.Position := DataStream.Position;
          j := 0;
          end;
        imgPreview.Refresh;
        i := 0;
        end;
      end;
    Caption := 'Preview stopped...';
    end; // if ms<>nil
end;

procedure TFormPreview.FormActivate(Sender: TObject);
begin
  aPlay.Execute;
end;

procedure TFormPreview.FormCreate(Sender: TObject);
begin
  DataStream := TMemoryStream.Create;
end;

procedure TFormPreview.FormDestroy(Sender: TObject);
begin
  FreeAndNil(DataStream);
end;

end.

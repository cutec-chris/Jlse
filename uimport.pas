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

unit uImport;

{$MODE Delphi}

interface

uses
   LCLIntf, LCLType, LMessages, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
   StdCtrls, Buttons, ComCtrls, ShellCtrls, FileUtil, uLaserFrames,
   uMain;

type
   TFormImport = class(TForm)
      bnCancel: TBitBtn;
      bnHelp: TBitBtn;
      bnImport: TBitBtn;
      cbFiletype: TComboBox;
      editFilename: TEdit;
      labelFilename: TStaticText;
      labelFiletype: TStaticText;
      labelSearchIn: TStaticText;
      lb: TListBox;
      scbDrives: TComboBox;
      slvFiles: TListView;
      procedure cbFiletypeChange(Sender: TObject);
      procedure editFilenameChange(Sender: TObject);
      procedure FormCreate(Sender: TObject);
      procedure lbClick(Sender: TObject);
      procedure lbDrawItem(Control: TWinControl; Index: Integer; Rect: TRect; State: TOwnerDrawState);
      procedure slvFilesClick(Sender: TObject);
   private
   public
      FFile: TLaserFrames;
   end;

var
   FormImport: TFormImport;

implementation

{$R *.lfm}

procedure TFormImport.lbDrawItem(Control: TWinControl; Index: Integer;
  Rect: TRect; State: TOwnerDrawState);
var clLine: TColor;
    sEffectName: string;
begin
   if Assigned(FFile)
    then if index<FFile.Count
     then with (Control as TListBox).Canvas
   do begin
      Brush.Color := clBlack;
      FillRect(Rect);
      Pen.Color := clGreen;
      Pen.Width := 1;
      if (odSelected in State) then begin
         Pen.Style := psDot;
         Rectangle(Rect.Left,Rect.Top,Rect.Right,Rect.Bottom);
      end;
      Pen.Style := psSolid;
      //MoveTo(Rect.Left,Rect.Bottom-1); LineTo(Rect.Right,Rect.Bottom-1);
      if ((TLaserFrame(FFile.frames[index]).Bits and 1)=0)
       then clLine := FormMain.MyColors[0,0] else clLine := FormMain.MyColors[1,0];
      FormMain.DrawThumb(TLaserFrame(FFile.frames[index]),(Control as TListBox).Canvas, Rect.Left,Rect.Top+2,4,clLine);
      Font.Color := clLime;
      TextOut(Rect.Left+66,Rect.Top+2,'Frame: ');
      TextOut(Rect.Left+66,Rect.Top+20,'Delay: ');
      TextOut(Rect.Left+66,Rect.Top+34,'Morph: ');
      TextOut(Rect.Left+66,Rect.Top+48,'Effect: ');
      TextOut(Rect.Left+106,Rect.Top+2,TLaserFrame(FFile.frames[index]).framename);
      TextOut(Rect.Left+106,Rect.Top+20,IntToStr(TLaserFrame(FFile.frames[index]).Delay));
      TextOut(Rect.Left+106,Rect.Top+34,IntToStr(TLaserFrame(FFile.frames[index]).Morph));
      case TLaserFrame(FFile.frames[index]).effect of
         0 : sEffectName := 'Slide';
         1 : sEffectName := 'Morph';
         2 : sEffectName := '-plode';
         3 : sEffectName := 'X-Flip';
         4 : sEffectName := 'Y-Flip';
      else sEffectName := '?';
      end;
      TextOut(Rect.Left+106,Rect.Top+48,sEffectName);
   end;
end;

procedure TFormImport.cbFiletypeChange(Sender: TObject);
begin
   (*
   // Filters not found in standard shell control
   if cbFiletype.ItemIndex = 1
    then ptFiles.FileFilter := '*.*'
     else ptFiles.FileFilter := '*.LC1';
   *)
end;

procedure TFormImport.slvFilesClick(Sender: TObject);
begin
   if Assigned(slvFiles.Selected) then begin
      //TODO:editFilename.Text := slvFiles.SelectedFolder.PathName + slvFiles.Selected.Caption;
      bnImport.Enabled := false;
   end;
end;

procedure TFormImport.editFilenameChange(Sender: TObject);
var i: integer;
begin
   if FileExistsUTF8(editFilename.Text) { *Converted from FileExists* } then begin
      lb.items.clear;
      FormMain.LoadFromFile(editFilename.Text, FFile, false);
      if Assigned(FFile)
      then for i := 0 to Pred(FFile.Count) do begin
         lb.items.add(TLaserFrame(FFile.Frames[i]).FrameName);
      end;
   end;
end;

procedure TFormImport.FormCreate(Sender: TObject);
begin
   // ptDrive.SelectedFolder.Pathname := ExtractFilePath(ParamStr(0));
   // ptFiles.Folder.Pathname := ExtractFilePath(ParamStr(0));
   cbFiletype.ItemIndex := 0;
end;

procedure TFormImport.lbClick(Sender: TObject);
begin
   bnImport.Enabled := (lb.ItemIndex>-1);
end;

end.

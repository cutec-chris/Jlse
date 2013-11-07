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

unit ucolors;

{$MODE Delphi}

interface

uses
   LCLIntf, LCLType, LMessages, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
   ExtCtrls, StdCtrls, Buttons, ComCtrls;

type
   TFormColors = class(TForm)
      bnCancel: TBitBtn;
      bnHelp: TBitBtn;
      bnOK: TBitBtn;
      bnUse: TBitBtn;
      cdPick: TColorDialog;
      editColor0: TEdit;
      editColor1: TEdit;
      groupFrameColors: TGroupBox;
      groupTextColors: TGroupBox;
      groupTimeline: TGroupBox;
      imgBack0: TImage;
      imgBack1: TImage;
      imgBackGround: TImage;
      imgHelpLines: TImage;
      imgLink0: TImage;
      imgLink1: TImage;
      imgNorm0: TImage;
      imgNorm1: TImage;
      imgReal0: TImage;
      imgReal1: TImage;
      imgRotCenter: TImage;
      imgSel0: TImage;
      imgSel1: TImage;
      imgThumbText: TImage;
      imgTimelineAreas: TImage;
      imgTimelineBack: TImage;
      imgTimelineLines: TImage;
      imgTimelineText: TImage;
      pcColors: TPageControl;
      stFrameColor0: TStaticText;
      stFrameColor1: TStaticText;
      stFrameColorBack: TStaticText;
      stFrameColorLinks: TStaticText;
      stFrameColorName: TStaticText;
      stFrameColorNormal: TStaticText;
      stFrameColorRound: TStaticText;
      stFrameColorSelected: TStaticText;
      stTextColorsBackGround: TStaticText;
      stTextColorsHelpLines: TStaticText;
      stTextColorsRotCenter: TStaticText;
      stTextColorsThumbText: TStaticText;
      stTimelineAreas: TStaticText;
      stTimelineBack: TStaticText;
      stTimelineLines: TStaticText;
      stTimelineText: TStaticText;
      tabColors: TTabSheet;
      tabOthers: TTabSheet;
      tabTimeline: TTabSheet;
      procedure bnUseClick(Sender: TObject);
      procedure imgBack0Click(Sender: TObject);
      procedure imgBack1Click(Sender: TObject);
      procedure imgBackGroundClick(Sender: TObject);
      procedure imgHelpLinesClick(Sender: TObject);
      procedure imgLink0Click(Sender: TObject);
      procedure imgLink1Click(Sender: TObject);
      procedure imgNorm0Click(Sender: TObject);
      procedure imgNorm1Click(Sender: TObject);
      procedure imgReal0Click(Sender: TObject);
      procedure imgReal1Click(Sender: TObject);
      procedure imgRotCenterClick(Sender: TObject);
      procedure imgSel0Click(Sender: TObject);
      procedure imgSel1Click(Sender: TObject);
      procedure imgThumbTextClick(Sender: TObject);
      procedure imgTimelineAreasClick(Sender: TObject);
      procedure imgTimelineBackClick(Sender: TObject);
      procedure imgTimelineLinesClick(Sender: TObject);
      procedure imgTimelineTextClick(Sender: TObject);
   private
   public
   end;

var
   FormColors: TFormColors;

implementation

uses uMain;

{$R *.lfm}

procedure FillCanvas(c: TImage; cl: TColor);
begin
   with c.canvas do begin
      Brush.Color := cl;
      FillRect(ClipRect);
      c.Tag := cl;
   end;
end;

procedure TFormColors.imgNorm0Click(Sender: TObject);
begin
   with cdPick do begin
      Color := imgNorm0.Tag;
      if cdPick.Execute then begin
         imgNorm0.Tag := Color;
         FillCanvas(imgNorm0, Color);
      end;
   end;
end;

procedure TFormColors.imgNorm1Click(Sender: TObject);
begin
   with cdPick do begin
      Color := imgNorm1.Tag;
      if cdPick.Execute then begin
         imgNorm1.Tag := Color;
         FillCanvas(imgNorm1, Color);
      end;
   end;

end;

procedure TFormColors.imgReal0Click(Sender: TObject);
begin
   with cdPick do begin
      Color := imgReal0.Tag;
      if cdPick.Execute then begin
         imgReal0.Tag := Color;
         FillCanvas(imgReal0, Color);
      end;
   end;

end;

procedure TFormColors.imgReal1Click(Sender: TObject);
begin
   with cdPick do begin
      Color := imgReal1.Tag;
      if cdPick.Execute then begin
         imgReal1.Tag := Color;
         FillCanvas(imgReal1, Color);
      end;
   end;

end;

procedure TFormColors.imgBack0Click(Sender: TObject);
begin
   with cdPick do begin
      Color := imgBack0.Tag;
      if cdPick.Execute then begin
         imgBack0.Tag := Color;
         FillCanvas(imgBack0, Color);
      end;
   end;

end;

procedure TFormColors.imgBack1Click(Sender: TObject);
begin
   with cdPick do begin
      Color := imgBack1.Tag;
      if cdPick.Execute then begin
         imgBack1.Tag := Color;
         FillCanvas(imgBack1, Color);
      end;
   end;

end;

procedure TFormColors.imgSel0Click(Sender: TObject);
begin
   with cdPick do begin
      Color := imgSel0.Tag;
      if cdPick.Execute then begin
         imgSel0.Tag := Color;
         FillCanvas(imgSel0, Color);
      end;
   end;

end;

procedure TFormColors.imgSel1Click(Sender: TObject);
begin
   with cdPick do begin
      Color := imgSel1.Tag;
      if cdPick.Execute then begin
         imgSel1.Tag := Color;
         FillCanvas(imgSel1, Color);
      end;
   end;
end;

procedure TFormColors.imgLink0Click(Sender: TObject);
begin
   with cdPick do begin
      Color := imgLink0.Tag;
      if cdPick.Execute then begin
         imgLink0.Tag := Color;
         FillCanvas(imgLink0, Color);
      end;
   end;

end;

procedure TFormColors.imgLink1Click(Sender: TObject);
begin
   with cdPick do begin
      Color := imgLink1.Tag;
      if cdPick.Execute then begin
         imgLink1.Tag := Color;
         FillCanvas(imgLink1, Color);
      end;
   end;

end;

procedure TFormColors.imgThumbTextClick(Sender: TObject);
begin
   with cdPick do begin
      Color := imgThumbText.Tag;
      if cdPick.Execute then begin
         imgThumbText.Tag := Color;
         FillCanvas(imgThumbText, Color);
      end;
   end;
end;

procedure TFormColors.bnUseClick(Sender: TObject);
begin
   FormMain.SetColorsFromDialog;
   FormMain.lbThumbs.Refresh;
   FormMain.Redraw;
end;

procedure TFormColors.imgBackGroundClick(Sender: TObject);
begin
   with cdPick do begin
      Color := imgBackground.Tag;
      if cdPick.Execute then begin
         imgBackground.Tag := Color;
         FillCanvas(imgBackground, Color);
      end;
   end;
end;

procedure TFormColors.imgHelpLinesClick(Sender: TObject);
begin
   with cdPick do begin
      Color := imgHelpLines.Tag;
      if cdPick.Execute then begin
         imgHelpLines.Tag := Color;
         FillCanvas(imgHelpLines, Color);
      end;
   end;
end;

procedure TFormColors.imgRotCenterClick(Sender: TObject);
begin
   with cdPick do begin
      Color := imgRotCenter.Tag;
      if cdPick.Execute then begin
         imgRotCenter.Tag := Color;
         FillCanvas(imgRotCenter, Color);
      end;
   end;
end;

procedure TFormColors.imgTimelineLinesClick(Sender: TObject);
begin
   with cdPick do begin
      Color := imgTimelineLines.Tag;
      if cdPick.Execute then begin
         imgTimelineLines.Tag := Color;
         FillCanvas(imgTimelineLines, Color);
      end;
   end;
end;

procedure TFormColors.imgTimelineAreasClick(Sender: TObject);
begin
   with cdPick do begin
      Color := imgTimelineAreas.Tag;
      if cdPick.Execute then begin
         imgTimelineAreas.Tag := Color;
         FillCanvas(imgTimelineAreas, Color);
      end;
   end;
end;

procedure TFormColors.imgTimelineTextClick(Sender: TObject);
begin
   with cdPick do begin
      Color := imgTimelineText.Tag;
      if cdPick.Execute then begin
         imgTimelineText.Tag := Color;
         FillCanvas(imgTimelineText, Color);
      end;
   end;
end;

procedure TFormColors.imgTimelineBackClick(Sender: TObject);
begin
   with cdPick do begin
      Color := imgTimelineBack.Tag;
      if cdPick.Execute then begin
         imgTimelineBack.Tag := Color;
         FillCanvas(imgTimelineBack,Color);
      end;
   end;
end;

end.

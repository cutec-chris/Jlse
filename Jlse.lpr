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

program Jlse;

{$MODE Delphi}

uses
  Forms,
  Interfaces,
  uStatus in 'FormUnitStatus.pas' {FormStatus},
  ucolors in 'FormUnitColors.pas' {FormColors},
  uDelays in 'FormUnitDelays.pas' {FormDelays},
  uhelplines in 'FormUnitHelpLines.pas' {FormHelpLines},
  uImport in 'FormUnitImport.pas' {fImport},
  uMain in 'FormUnitMain.pas' {FormMain},
  uPad in 'FormUnitPad.pas' {FormSketchpad},
  upick in 'FormUnitPick.pas' {FormPickImage},
  uPreview in 'FormUnitPreview.pas' {FormPreview};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TFormMain, FormMain);
  Application.CreateForm(TFormStatus, FormStatus);
  Application.CreateForm(TFormColors, FormColors);
  Application.CreateForm(TFormDelays, FormDelays);
  Application.CreateForm(TFormHelpLines, FormHelpLines);
  Application.CreateForm(TFormImport, FormImport);
  Application.CreateForm(TFormSketchpad, FormSketchpad);
  Application.CreateForm(TFormPickImage, FormPickImage);
  Application.CreateForm(TFormPreview, FormPreview);
  Application.Run;
end.

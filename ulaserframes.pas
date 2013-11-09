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

unit uLaserFrames;

{$mode delphi}

interface

uses
  Classes, SysUtils, Graphics, FileUtil;

type
  THelpLines = class
    x, y: array of byte;
    d: array[0..1] of array of TPoint;
  end;

  TLaserFrames = class;
  TLaserPoint = class;

  { TLaserFrame }

  TLaserFrame = class(TPersistent)
  protected
    procedure Assign(sf: TLaserFrame); reintroduce;
  public
    Delay, Morph, Bits: word;
    FrameName: string;
    ImgName: string;
    Links: array of array of boolean;
    HelpLines: THelpLines;
    Effect: word;
    EffectParam: smallint;
    RotCenter: TPoint;
    AuxCenter: TPoint;
    Bitmap: TBitmap;
    ImgRect: TRect;
    Points: TList;
    Parent : TLaserFrames;
    function Add: TLaserPoint;virtual;
    constructor Create;
    destructor Destroy; reintroduce;
    function LoadFromStream(aStream : TStream) : Boolean;virtual;
    procedure SaveToStream(aStream : TStream);virtual;
  end;

  { TLaserFrames }

  TLaserFrames = class(TObject)
  private
    FFrames: TList;
    FFrameCount: integer;
    FOldPointCount: integer;
    FFileVersion: byte;
    function GetCount: integer;
    function GetFrames(FrameIndex: integer): TLaserFrame;
  public
    Filename: string;
    constructor Create;
    destructor Destroy; reintroduce;
    property FileVersion : byte read FFileVersion;
    property OldPointCount : Integer read FOldPointCount write FOldPointCount;
    function Add: TLaserFrame; overload;virtual;
    function Add(Frame: TLaserFrame): integer; overload;
    procedure Insert(Position: integer; Frame: TLaserFrame);
    procedure Delete(FrameIndex: integer);
    procedure Clear;
    function LoadHeaderFromStream(aStream : TStream) : Boolean;virtual;
    procedure SaveHeaderToStream(aStream : TStream);virtual;
    procedure LoadFromStream(aStream : TStream);virtual;
    procedure SaveToStream(aStream : TStream);virtual;
    procedure LoadFromFile(Filename: string);
    property Count: integer read GetCount;
    property Frames[FrameIndex: integer]: TLaserFrame read GetFrames;
  end;

  TLaserFramesClass = class of TLaserFrames;

  { TLaserPoint }

  TLaserPoint = class(TObject)
  public
    Caption: string[5];
    X, Y: word;
    p: smallint;
    bits: word;
    overlay: boolean;
    Parent : TLaserFrame;
    constructor Create;
    destructor Destroy; reintroduce;
    procedure Assign(sp: TLaserPoint);
    function LoadFromStream(aStream : TStream) : Boolean;virtual;
    procedure SaveToStream(aStream : TStream);virtual;
  end;

  TFileCapTyp = (fcLoad,fcSave);
  TFileCapTyps = set of TFileCapTyp;

  TFileFormat = class
  public
    FileClass       : TLaserFramesClass;
    Extension       : String;
    Description     : String;
    Types           : TFileCapTyps;
  end;

  { TFileFormatsList }

  TFileFormatsList = class (tlist)
  public
    destructor Destroy; override;
    procedure Add(const Ext, Desc: String; AClass: TLaserFramesClass;Typs : TFileCapTyps);
    function FindExt(ext : string;Typs : TFileCapTyps) : TLaserFramesClass;
    function FindFromFileName(const fileName : String;Typs : TFileCapTyps) : TLaserFramesClass;
    procedure BuildFilterStrings(var descriptions: String;Typs : TFileCapTyps);
  end;

var
  FileFormats : TFileFormatsList;

implementation
resourcestring
  strUnknownExtension                = 'Unknown File Extension';
  strAllFormats                      = 'All supported Formats';
{ TFileFormatsList }

destructor TFileFormatsList.Destroy;
begin
  inherited Destroy;
end;

procedure TFileFormatsList.Add(const Ext, Desc: String;
  AClass: TLaserFramesClass; Typs: TFileCapTyps);
var
   newRec : TFileFormat;
begin
   newRec:=TFileFormat.Create;
   with newRec do
     begin
       Extension:=LowerCase(Ext);
       FileClass:=AClass;
       Description:=Desc;
       Types := Typs;
     end;
   inherited Add(newRec);
end;

function TFileFormatsList.FindExt(ext: string; Typs: TFileCapTyps
  ): TLaserFramesClass;
var
   i : Integer;
begin
   ext:=LowerCase(ext);
   for i:=Count-1 downto 0 do
     with TFileFormat(Items[I]) do
       begin
         if ((fcLoad in Typs) and (fcLoad in TFileFormat(Items[I]).Types)) or ((fcSave in Typs) and (fcSave in TFileFormat(Items[I]).Types)) then
           if Extension=ext then
             begin
               Result:=TFileFormat(Items[I]).FileClass;
               Exit;
             end;
       end;
   Result:=nil;
end;

function TFileFormatsList.FindFromFileName(const fileName: String;
  Typs: TFileCapTyps): TLaserFramesClass;
var
   ext : String;
begin
   ext:=ExtractFileExt(Filename);
   System.Delete(ext, 1, 1);
   Result:=FindExt(ext,Typs);
   if not Assigned(Result) then
      raise Exception.CreateFmt(strUnknownExtension, [ext]);
end;

procedure TFileFormatsList.BuildFilterStrings(var descriptions: String;
  Typs: TFileCapTyps);
var
   k, i : Integer;
   p : TFileFormat;
   filters : string;
begin
   descriptions:='';
   filters := '';
   k:=0;
   for i:=0 to Count-1 do
     begin
       p:=TFileFormat(Items[i]);
       if ((fcLoad in Typs) and (fcLoad in p.Types) or ((fcSave in Typs) and (fcSave in p.Types))) then
         with p do
           begin
             if k<>0 then
               begin
                 descriptions:=descriptions+'|';
                 filters := filters+';';
               end;
            descriptions:=descriptions+Description+' (*.'+Extension+')|'+'*.'+Extension;
            filters := filters+'*.'+Extension;
            Inc(k);
         end;
      end;
   descriptions := strAllFormats+'|'+filters+'|'+descriptions;
end;

function TLaserFrames.Add: TLaserFrame;
begin
  Result := TLaserFrame.Create;
  Result.Parent:=Self;
  FFrames.Add(Result);
end;

function TLaserFrames.Add(Frame: TLaserFrame): integer;
begin
  Result := FFrames.Add(Frame);
end;

procedure TLaserFrames.Clear;
var
  i: integer;
begin
  for i := 0 to Pred(Count) do
    begin
    Frames[i].Free;
    end;
  FFrames.Clear;
end;

function TLaserFrames.LoadHeaderFromStream(aStream: TStream): Boolean;
var
  s1: array[1..4] of char;
  b : byte;
begin
  Result := True;
  FFrameCount := 0;
  FOldPointCount := 0;
  Clear;
  if aStream.Size > 5 then
    begin
      aStream.Read(s1,4);
      aStream.Read(b,1);
      FFileVersion := b;
      if not (s1 = 'LC1Y') then Result := False;
    end
  else Result := False;
end;

procedure TLaserFrames.SaveHeaderToStream(aStream: TStream);
begin

end;

procedure TLaserFrames.LoadFromStream(aStream: TStream);
var
  i: integer;
  fFrame: TLaserFrame;
begin
  if LoadHeaderfromStream(aStream) then
    begin
      while aStream.Position<aStream.Size do
        begin
          Inc(FFrameCount);
          fFrame := Add;
          fFrame.LoadFromStream(aStream);
        end; // while not eof
    end;
end;

procedure TLaserFrames.SaveToStream(aStream: TStream);
begin

end;

constructor TLaserFrames.Create;
begin
  FFrames := TList.Create;
  Filename := '';
  inherited Create;
end;

procedure TLaserFrames.Delete(FrameIndex: integer);
begin
  Frames[FrameIndex].Free;
  FFrames.Delete(FrameIndex);
end;

destructor TLaserFrames.Destroy;
begin
  FreeAndNil(FFrames);
  inherited Destroy;
end;

function TLaserFrames.GetCount: integer;
begin
  Result := FFrames.Count;
end;

function TLaserFrames.GetFrames(FrameIndex: integer): TLaserFrame;
begin
  Result := TLaserFrame(FFrames[FrameIndex]);
end;

procedure TLaserFrames.Insert(Position: integer; Frame: TLaserFrame);
begin
  FFrames.Insert(Position, Frame);
end;

procedure TLaserFrames.LoadFromFile(Filename: string);
var
  aStream: TFileStream;
begin
  if FileExistsUTF8(Filename) then
    begin
      aStream := TfileStream.Create(Filename,fmShareDenyNone);
      Self.Filename := Filename;
      LoadFromStream(aStream);
      aStream.Free;
    end;
end;

{ TLaserFrame }

constructor TLaserFrame.Create;
begin
  Points := TList.Create;
  FrameName := '';
  ImgName := '';
  Effect := 0;
  SetLength(Links, 0, 0);
  Bitmap := TBitmap.Create;
  Delay := 1000;
  Morph := 0;
  RotCenter.X := 128;
  RotCenter.Y := 128;
  AuxCenter.X := 128;
  AuxCenter.Y := 128;
  HelpLines := THelpLines.Create;
  SetLength(HelpLines.x, 0);
  SetLength(HelpLines.y, 0);
  SetLength(HelpLines.d[0], 0);
  SetLength(HelpLines.d[1], 0);
  inherited Create;
end;

destructor TLaserFrame.Destroy;
begin
  FreeAndNil(HelpLines);
  FreeAndNil(Points);
  Links := nil;
  inherited Destroy;
end;

function TLaserFrame.LoadFromStream(aStream: TStream): Boolean;
var
  pPoint: TLaserPoint;
  w: word;
  s: string;
  c: char;
  tr: TRect;
  b, bb: byte;
  mx, my, cx, cy: word;
  rword: word;
  i: Integer;
begin
  Result := True;
  // frame name
  aStream.Read(w,2);
  s := '';
  for i := 1 to w do
    begin
      aStream.Read(c, 1);
      s := s + c;
    end;
  FrameName := s;
  // frame delay
  aStream.Read(Delay, 2); // delay 4 frame
  // frame morph time
  aStream.Read( Morph, 2); // morph-time 4 frame
  // effect type
  aStream.Read( Effect, 2);
  // effect param
  if Parent.FileVersion > 3 then
    aStream.Read( EffectParam, 2);
  // rotcenter
  if Parent.FileVersion > 4 then
    begin
      aStream.Read( RotCenter.x, 1);
      aStream.Read( RotCenter.y, 1);
    end
  else
    begin
      RotCenter.x := 128;
      RotCenter.y := 128;
    end;
  // rotcenter
  if Parent.FileVersion > 5 then
    begin
      aStream.Read( AuxCenter.x, 1);
      aStream.Read( AuxCenter.y, 1);
    end
  else
    begin
      AuxCenter.x := 128;
      AuxCenter.y := 128;
    end;
  // bits for stuff
  if Parent.FileVersion > 1 then
    aStream.Read( Bits, 2)
  else
    Bits := 0;
  // framelist
  // img name
  aStream.Read( w, 2); // size of name
  s := '';
  for i := 1 to w do
    begin
      aStream.Read( c, 1);
      s := s + c;
    end;
  ImgName := s;
  if FileExistsUTF8(ImgName) then
    begin
      if bitmap = nil then
        bitmap := TBitmap.Create;
      bitmap.LoadFromFile(ImgName);
    end;
    // img size
    aStream.Read( tr, sizeof(TRect));
    ImgRect := tr;
    // helplines
    if Parent.FileVersion > 2 then
      begin
        aStream.Read( w, 2);
        SetLength(HelpLines.x, w);
        if w > 0 then
          for i := 0 to Pred(w) do
            begin
              aStream.Read( bb, 1);
              HelpLines.x[i] := bb;
            end;
          aStream.Read( w, 2);
          SetLength(HelpLines.y, w);
          if w > 0 then
            for i := 0 to Pred(w) do
              begin
                aStream.Read( bb, 1);
                HelpLines.y[i] := bb;
              end;
          aStream.Read( w, 2);
          SetLength(HelpLines.d[0], w);
          SetLength(HelpLines.d[1], w);
          if w > 0 then
            for i := 0 to Pred(w) do
              begin
                aStream.Read( bb, 1);
                HelpLines.d[0, i].x := bb;
                aStream.Read( bb, 1);
                HelpLines.d[0, i].y := bb;
                aStream.Read( bb, 1);
                HelpLines.d[1, i].x := bb;
                aStream.Read( bb, 1);
                HelpLines.d[1, i].y := bb;
              end;
      end;
    // points
    aStream.Read( w, 2); // num points
    for i := 0 to Pred(w) do
      begin
        pPoint := Add;
        pPoint.LoadFromStream(aStream);
      end;
    SetLength(links, w, Parent.OldPointCount);
    Parent.OldPointCount := w;
    aStream.Read( mx, 2);
    aStream.Read( my, 2);
    if (mx > 0) and (my > 0) then
      begin
        for cy := 0 to Pred(my) do
          begin
            cx := 0;
            while cx < mx do
              begin
                if ((cx mod 16) = 0) then
                  aStream.Read( rword, 2);
                links[cx, cy] := (rword and (1 shl (cx mod 16)) > 0);
                Inc(cx);
              end;
          end;
      end;
end;

procedure TLaserFrame.SaveToStream(aStream: TStream);
begin

end;

procedure TLaserFrame.Assign(sf: TLaserFrame);
var
  i, j: integer;
  newp, myp: TLaserPoint;
begin
  self.Bitmap.Assign(sf.Bitmap);
  self.Bits := sf.Bits;
  self.Delay := sf.Delay;
  self.Effect := sf.Effect;
  self.EffectParam := sf.EffectParam;
  self.RotCenter := sf.RotCenter;
  self.AuxCenter := sf.AuxCenter;
  self.FrameName := sf.FrameName;
  SetLength(self.HelpLines.x, Length(sf.HelpLines.x));
  for i := 0 to Pred(Length(self.HelpLines.x)) do
    self.HelpLines.x[i] := sf.HelpLines.x[i];
  SetLength(self.HelpLines.y, Length(sf.HelpLines.y));
  for i := 0 to Pred(Length(self.HelpLines.y)) do
    self.HelpLines.y[i] := sf.HelpLines.y[i];
  SetLength(self.HelpLines.d[0], Length(sf.HelpLines.d[0]));
  SetLength(self.HelpLines.d[1], Length(sf.HelpLines.d[1]));
  for i := 0 to Pred(Length(self.HelpLines.d[0])) do
    self.HelpLines.d[0, i] := sf.HelpLines.d[0, i];
  for i := 0 to Pred(Length(self.HelpLines.d[1])) do
    self.HelpLines.d[1, i] := sf.HelpLines.d[1, i];
  self.imgname := sf.imgname;
  self.ImgRect := sf.ImgRect;
  self.Morph := sf.Morph;
  SetLength(self.links, Length(sf.links));
  for i := 0 to Pred(Length(sf.links)) do
    begin
    SetLength(self.links[i], Length(sf.links[i]));
    for j := 0 to Pred(Length(sf.links[i])) do
      begin
      self.links[i, j] := sf.links[i, j];
      end;
    end;
  self.Points.Clear;
  for i := 0 to Pred(sf.Points.Count) do
    begin
    newp := TLaserPoint.Create;
    myp := sf.Points[i];
    newp.Assign(myp);
    self.Points.add(newp);
    end;
end;

function TLaserFrame.Add: TLaserPoint;
begin
  Result := TLaserPoint.Create;
  Points.add(Result);
  Result.Parent:=Self;
end;

{ TLaserPoint }

constructor TLaserPoint.Create;
begin
  p := -1;
  overlay := False;
  inherited Create;
end;

destructor TLaserPoint.Destroy;
begin
  inherited Destroy;
end;

procedure TLaserPoint.Assign(sp: TLaserPoint);
begin
  Caption := sp.Caption;
  x := sp.X;
  y := sp.Y;
  p := sp.p;
  bits := sp.bits;
  overlay := sp.overlay;
end;

function TLaserPoint.LoadFromStream(aStream: TStream): Boolean;
var
  s2: array[1..11] of char;
begin
  if Parent.Parent.FileVersion > 1 then
    aStream.Read( s2, 11)
  else
    aStream.Read( s2, 9);
  Caption := s2[1] + s2[2] + s2[3] + s2[4] + s2[5];
  if Pos(#0, Caption) > 0 then
    Caption := Copy(Caption, 1, Pos(#0, Caption) - 1);
  x := Ord(s2[6]);
  y := Ord(s2[7]);
  p := 0;
  if Parent.Parent.FileVersion > 1 then
    begin
      bits := Ord(s2[10]) * 256 + Ord(s2[11]);
    end
  else
    bits := 0;
end;

procedure TLaserPoint.SaveToStream(aStream: TStream);
begin

end;

initialization
  FileFormats := TFileFormatsList.Create;
  FileFormats.Add('LC1','Youghurt Format',TLaserFrames,[fcSave,fcLoad]);
  //FileFormats.Add('lc1-frame','Youghurt Frame',TLC1Frames,[fcSave,fcLoad]);

finalization
  FileFormats.Free;
end.

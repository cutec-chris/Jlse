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
      x,y: array of byte;
      d: array[0..1] of array of TPoint;
   end;

  TLaserFrame = class(TPersistent)
  protected
     procedure Assign(sf: TLaserFrame); reintroduce;
  public
     Delay, Morph, Bits: Word;
     FrameName: String;
     ImgName: string;
     Links: array of array of boolean;
     HelpLines: THelpLines;
     Effect: Word;
     EffectParam: SmallInt;
     RotCenter: TPoint;
     AuxCenter: TPoint;
     Bitmap: TBitmap;
     ImgRect: TRect;
     Points: TList;
     constructor Create;
     destructor Destroy; reintroduce;
  end;

  TLaserFrames = class(TObject)
  private
     FFrames: TList;
     function GetCount: integer;
     function GetFrames(FrameIndex: integer): TLaserFrame;
  public
     Filename: string;
     constructor Create;
     destructor Destroy; reintroduce;
     function Add: TLaserFrame; overload;
     function Add(Frame: TLaserFrame): integer; overload;
     procedure Insert(Position: integer; Frame: TLaserFrame);
     procedure Delete(FrameIndex: integer);
     procedure Clear;
     procedure LoadFromFile(Filename: string);
     property Count: integer read GetCount;
     property Frames[FrameIndex: integer]: TLaserFrame read GetFrames;
  end;

   TSmallPoint = class(TObject)
   public
      Caption: String[5];
      X,Y: word;
      p: smallint;
      bits: word;
      overlay: boolean;
      constructor Create;
      destructor Destroy; reintroduce;
      procedure Assign(sp: TSmallPoint);
   end;

implementation

function TLaserFrames.Add: TLaserFrame;
begin
   Result := TLaserFrame.Create;
   FFrames.Add(Result);
end;

function TLaserFrames.Add(Frame: TLaserFrame): integer;
begin
   Result := FFrames.Add(Frame);
end;

procedure TLaserFrames.Clear;
var i: integer;
begin
   for i := 0 to Pred(Count) do begin
      Frames[i].Free;
   end;
   FFrames.Clear;
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
var f: file;
    i: integer;
    fFrame: TLaserFrame;
    pPoint: TSmallPoint;
    s1: array[1..4] of char;
    s2: array[1..11] of char;
    w: word;
    s: string;
    c: char;
    tr: TRect;
    b,bb: byte;
    iFrameCount: integer;
    iOldPointCount: integer;
    mx,my,cx,cy: word;
    rword: word;
    bFileVersion: byte;
begin
   if FileExistsUTF8(Filename) then begin
      iFrameCount := 0;
      FileMode := 0;
      iOldPointCount := 0;
      AssignFile(f, Filename);
      Reset(f, 1);
      Self.Filename := Filename;
      Clear;
      if FileSize(f)>5 then begin
         BlockRead(f,s1,4);
         BlockRead(f,b,1);
         bFileVersion := b;
         if s1 = 'LC1Y' then begin
            while not EoF(f) do begin
               Inc(iFrameCount);
               fFrame := Add;
               // frame name
               BlockRead(f,w,2); // size of name
               s := '';
               for i := 1 to w do begin
                  BlockRead(f,c,1);
                  s := s + c;
               end;
               fFrame.FrameName := s;
               // frame delay
               BlockRead(f,fFrame.Delay,2); // delay 4 frame
               // frame morph time
               BlockRead(f,fFrame.Morph,2); // morph-time 4 frame
               // effect type
               BlockRead(f,fFrame.Effect,2);
               // effect param
               if bFileVersion>3 then BlockRead(f,fFrame.EffectParam,2);
               // rotcenter
               if bFileVersion>4 then begin
                  BlockRead(f,fFrame.RotCenter.x,1);
                  BlockRead(f,fFrame.RotCenter.y,1);
               end else begin
                  fFrame.RotCenter.x := 128;
                  fFrame.RotCenter.y := 128;
               end;
               // rotcenter
               if bFileVersion>5 then begin
                  BlockRead(f,fFrame.AuxCenter.x,1);
                  BlockRead(f,fFrame.AuxCenter.y,1);
               end else begin
                  fFrame.AuxCenter.x := 128;
                  fFrame.AuxCenter.y := 128;
               end;
               // bits for stuff
               if bFileVersion > 1 then BlockRead(f,fFrame.Bits,2) else fFrame.Bits := 0;
               // framelist
               // img name
               BlockRead(f,w,2); // size of name
               s := '';
               for i := 1 to w do begin
                  BlockRead(f,c,1);
                  s := s + c;
               end;
               fFrame.ImgName := s;
               if FileExistsUTF8(fFrame.ImgName) { *Converted from FileExists* } then begin
                  if fFrame.bitmap=nil then fFrame.bitmap := TBitmap.Create;
                  fFrame.bitmap.LoadFromFile(fFrame.ImgName);
               end;
               // img size
               BlockRead(f,tr,sizeof(TRect));
               fFrame.ImgRect := tr;
               // helplines
               if bFileVersion>2 then begin
                  BlockRead(f,w,2);
                  SetLength(fFrame.HelpLines.x,w);
                  if w>0 then
                    for i := 0 to Pred(w) do begin
                       BlockRead(f,bb,1);
                       fFrame.HelpLines.x[i] := bb;
                    end;
                  BlockRead(f,w,2);
                  SetLength(fFrame.HelpLines.y,w);
                  if w>0 then
                    for i := 0 to Pred(w) do begin
                       BlockRead(f,bb,1);
                       fFrame.HelpLines.y[i] := bb;
                    end;
                  BlockRead(f,w,2);
                  SetLength(fFrame.HelpLines.d[0],w);
                  SetLength(fFrame.HelpLines.d[1],w);
                  if w>0 then
                    for i := 0 to Pred(w) do begin
                       BlockRead(f,bb,1);
                       fFrame.HelpLines.d[0,i].x := bb;
                       BlockRead(f,bb,1);
                       fFrame.HelpLines.d[0,i].y := bb;
                       BlockRead(f,bb,1);
                       fFrame.HelpLines.d[1,i].x := bb;
                       BlockRead(f,bb,1);
                       fFrame.HelpLines.d[1,i].y := bb;
                    end;
               end;
               // points
               BlockRead(f,w,2); // num points
               for i := 0 to Pred(w) do begin
                  if bFileVersion>1 then BlockRead(f,s2,11)
                  else BlockRead(f,s2,9);
                  pPoint := TSmallPoint.Create;
                  pPoint.Caption := s2[1]+s2[2]+s2[3]+s2[4]+s2[5];
                  if Pos(#0,pPoint.Caption)>0 then pPoint.Caption := Copy(pPoint.Caption,1,Pos(#0,pPoint.Caption)-1);
                  pPoint.x := Ord(s2[6]);
                  pPoint.y := Ord(s2[7]);
                  //myp.p := Ord(s2[8])*256+Ord(s2[9]);
                  pPoint.p := 0;
                  if bFileVersion>1 then begin
                     pPoint.bits := Ord(s2[10])*256+Ord(s2[11]);
                  end else pPoint.bits := 0;
                  fFrame.Points.add(pPoint);
               end;
               SetLength(fFrame.links,w,iOldPointCount);
               iOldPointCount := w;
               BlockRead(f,mx,2);
               BlockRead(f,my,2);
               if (mx>0) and (my>0) then begin
                  for cy := 0 to Pred(my) do begin
                     cx := 0;
                     while cx<mx do begin
                        if ((cx mod 16)=0) then BlockRead(f,rword,2);
                        fFrame.links[cx,cy] := (rword and (1 shl (cx mod 16))>0);
                        Inc(cx);
                     end;
                  end;
               end;
            end; // while not eof
         end; // if lc1y
      end; // if fs>5
      CloseFile(f);
   end; // if fileexists fn
end;

{ TLaserFrame }

constructor TLaserFrame.Create;
begin
   Points := TList.Create;
   FrameName := '';
   ImgName := '';
   Effect := 0;
   SetLength(Links,0,0);
   Bitmap := TBitmap.Create;
   Delay := 1000;
   Morph := 0;
   RotCenter.X := 128;
   RotCenter.Y := 128;
   AuxCenter.X := 128;
   AuxCenter.Y := 128;
   HelpLines := THelpLines.Create;
   SetLength(HelpLines.x,0);
   SetLength(HelpLines.y,0);
   SetLength(HelpLines.d[0],0);
   SetLength(HelpLines.d[1],0);
   inherited Create;
end;

destructor TLaserFrame.Destroy;
begin
   FreeAndNil(HelpLines);
   FreeAndNil(Points);
   Links := nil;
   inherited Destroy;
end;

procedure TLaserFrame.Assign(sf: TLaserFrame);
var i,j: integer;
    newp,myp: TSmallPoint;
begin
   self.Bitmap.Assign(sf.Bitmap);
   self.Bits := sf.Bits;
   self.Delay := sf.Delay;
   self.Effect := sf.Effect;
   self.EffectParam := sf.EffectParam;
   self.RotCenter := sf.RotCenter;
   self.AuxCenter := sf.AuxCenter;
   self.FrameName := sf.FrameName;
   SetLength(self.HelpLines.x,Length(sf.HelpLines.x));
   for i := 0 to Pred(Length(self.HelpLines.x))
    do self.HelpLines.x[i] := sf.HelpLines.x[i];
   SetLength(self.HelpLines.y,Length(sf.HelpLines.y));
   for i := 0 to Pred(Length(self.HelpLines.y))
    do self.HelpLines.y[i] := sf.HelpLines.y[i];
   SetLength(self.HelpLines.d[0],Length(sf.HelpLines.d[0]));
   SetLength(self.HelpLines.d[1],Length(sf.HelpLines.d[1]));
   for i := 0 to Pred(Length(self.HelpLines.d[0]))
    do self.HelpLines.d[0,i] := sf.HelpLines.d[0,i];
   for i := 0 to Pred(Length(self.HelpLines.d[1]))
    do self.HelpLines.d[1,i] := sf.HelpLines.d[1,i];
   self.imgname := sf.imgname;
   self.ImgRect := sf.ImgRect;
   self.Morph := sf.Morph;
   SetLength(self.links,Length(sf.links));
   for i := 0 to Pred(Length(sf.links)) do begin
      SetLength(self.links[i],Length(sf.links[i]));
      for j := 0 to Pred(Length(sf.links[i])) do begin
         self.links[i,j] := sf.links[i,j];
      end;
   end;
   self.Points.clear;
   for i := 0 to Pred(sf.Points.Count) do begin
      newp := TSmallPoint.Create;
      myp := sf.Points[i];
      newp.Assign(myp);
      self.Points.add(newp);
   end;
end;

{ TSmallPoint }

constructor TSmallPoint.Create;
begin
   p := -1;
   overlay := false;
   inherited Create;
end;

destructor TSmallPoint.Destroy;
begin
   inherited Destroy;
end;

procedure TSmallPoint.Assign(sp: TSmallPoint);
begin
   Caption := sp.Caption;
   x := sp.X;
   y := sp.Y;
   p := sp.p;
   bits := sp.bits;
   overlay := sp.overlay;
end;

end.


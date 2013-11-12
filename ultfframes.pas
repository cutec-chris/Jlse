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

unit ultfframes;

{$mode delphi}

interface

uses
  Classes, SysUtils, uLaserFrames;

type

  { TLTFFrame }

  TLTFFrame = class(TLaserFrame)
  private
    FPPS: Cardinal;
  protected
    FNumber: Cardinal;
  public
    property PPS : Cardinal read FPPS write FPPS;
    property Number : Cardinal read FNumber write FNumber;
    function Add: TLaserPoint; override;
    function LoadFromStream(aStream: TStream): Boolean; override;
  end;

  { TLTFPoint }

  TLTFPoint = class(TLaserPoint)
  private
    procedure SetColorIndex(AValue: Integer);
  public
    function LoadFromStream(aStream: TStream): Boolean; override;
    property ColorIndex : Integer write SetColorIndex;
  end;

  { TLTFFrames }

  TLTFFrames = class(TLaserFrames)
  public
    constructor Create; override;
    function Add: TLaserFrame; overload; override;
    function LoadHeaderFromStream(aStream: TStream): Boolean;override;
    procedure LoadFromStream(aStream: TStream); override;
    procedure ReadFrameData(aStream:TStream;TagLen:Cardinal);
    function ReadStringData(aStream:TStream;TagLen:Cardinal) : string;
  end;

implementation

{ TLTFFrame }

function TLTFFrame.Add: TLaserPoint;
begin
  Result:=TLTFPoint.Create;
  Result.Parent:=Self;
  Points.Add(Result);
end;

function TLTFFrame.LoadFromStream(aStream: TStream): Boolean;
begin
end;

procedure TLTFPoint.SetColorIndex(AValue: Integer);
begin

end;

function TLTFPoint.LoadFromStream(aStream: TStream): Boolean;
begin
end;

{ TLTFFrames }

constructor TLTFFrames.Create;
begin
  inherited Create;
end;

function TLTFFrames.Add: TLaserFrame;
begin
  Result:=TLTFFrame.Create(Self);
  Add(Result);
end;

function TLTFFrames.LoadHeaderFromStream(aStream: TStream): Boolean;
var
  s1: array[1..3] of char;
  b : byte;
  u32 : Cardinal;
begin
  Result := True;
  Clear;
  if aStream.Size > 4 then
    begin
      aStream.Read(s1,3);
      aStream.Read(b,1);
      FileVersion := b;
      if not (s1 = 'LTF') then Result := False;
    end
  else Result := False;
  aStream.Read(u32,4);//Count of Tags
  aStream.Read(u32,4);//TagImage1count
  aStream.Read(u32,4);//reserved
end;

procedure TLTFFrames.LoadFromStream(aStream: TStream);
var
  TagId,b : byte;
  TagLen : Cardinal;
  aLen: Cardinal;
  CompanyName: String;
  aFrameName: String;
  aPPS : Cardinal;
begin
  if not LoadHeaderFromStream(aStream) then exit;
  Repeat
    aStream.Read(TagId,1);
    aStream.Read(TagLen,1);
    if TagLen=255 then
      aStream.Read(TagLen,4);
    case Tagid of
    //TagColorTable  1:ReadColorTable(aStream,TagLen);
    //TagHersteller
    2:CompanyName := ReadStringData(aStream,TagLen);
    //TagImageName:
    3:aFrameName := ReadStringData(aStream,TagLen);
    //TagSetPPS
    4:aStream.Read(aPPS,4);
    //TagImage1
    10:ReadFrameData(aStream,TagLen);
     else
       begin
         aLen := tagLen;
         while aLen>0 do
           begin
             aStream.Read(b,1);
             dec(aLen);
           end;
       end;
    end;
  until TagId=0;
end;

type
  PT_XYZ8_PAL = record
    X,Y,Z : ShortInt;
    Status : byte;
  end;
  PT_XY8_PAL = record
    X,Y : ShortInt;
    Status : byte;
  end;
  PT_XYZ16_PAL = record
    X,Y,Z : SmallInt;
    Status : byte;
  end;
  PT_XY16_PAL = record
    X,Y : SmallInt;
    Status : byte;
  end;

procedure TLTFFrames.ReadFrameData(aStream: TStream; TagLen: Cardinal);
var
  aFrame: TLTFFrame;
  Points_Total : Cardinal;
  Frame_Repeat,PointType : byte;

  XYZ8_PAL : PT_XYZ8_PAL;
  XY8_PAL : PT_XY8_PAL;
  XYZ16_PAL : PT_XYZ16_PAL;
  XY16_PAL : PT_XY16_PAL;
  i: Integer;
  aPoint: TLTFPoint;
begin
  aFrame := TLTFFrame(Add);
  aStream.Read(aFrame.FNumber,2);
  aStream.Read(Points_Total,2);
  aStream.Read(Frame_Repeat,1);
  aStream.Read(PointType,1);
  for i := 0 to Points_Total-1 do
    begin
      aPoint := TLTFPoint(aFrame.Add);
      case PointType of
      0,1:
        begin
          if PointType and 1=1 then
            aStream.Read(XYZ8_PAL,sizeof(PT_XYZ8_PAL))
          else
            aStream.Read(XY8_PAL,sizeof(PT_XY8_PAL));
          aPoint.X := XYZ8_PAL.X;
          aPoint.Y := XYZ8_PAL.Y;
          if PointType and 1=1 then
            begin
              aPoint.Z := XYZ8_PAL.Z;
              aPoint.Blanking := (XYZ8_PAL.Status and $80) = $80;
              aPoint.ColorIndex := (XYZ8_PAL.Status and $7F);
            end
          else
            begin
              aPoint.Blanking := (XY8_PAL.Status and $80) = $80;
              aPoint.ColorIndex := (XY8_PAL.Status and $7F);
            end;
        end;
      2,3:;
      4,5:;
      6,7:;
      8,9:;
      10,11:;
      12,13:;
      end;
    end;
end;

function TLTFFrames.ReadStringData(aStream: TStream; TagLen: Cardinal): string;
begin
  Setlength(Result,TagLen);
  aStream.Read(Result[1],TagLen);
end;

initialization
//  FileFormats.Add('ltf','Laserimage Transfer Format',TLTFFrames,[fcLoad]);

end.


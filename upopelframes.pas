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

unit upopelframes;

{$mode delphi}

interface

uses
  Classes, SysUtils, uLaserFrames,Graphics;

type

  { TMOTFrame }

  TMOTFrame = class(TLaserFrame)
  protected
  public
    CompanyName : string;
    function Add: TLaserPoint; override;
    function LoadFromString(aStr : string): Boolean;
  end;

  { TMOTPoint }

  TMOTPoint = class(TLaserPoint)
  public
  end;

  { TMOTFrames }

  TMOTFrames = class(TLaserFrames)
  private
    FBlankDelay: Integer;
    FPointDelay: Integer;
    FSL : TStringList;
    NumPoints: Integer;
  public
    constructor Create; override;
    destructor Destroy; reintroduce;
    property PointDelay : Integer read FPointDelay;
    property BlankDelay : Integer read FBlankDelay;
    function Add: TLaserFrame; overload; override;
    function LoadHeaderFromStream(aStream: TStream): Boolean;override;
    procedure LoadFromStream(aStream: TStream); override;
  end;

implementation

{ TMOTFrame }

function TMOTFrame.Add: TLaserPoint;
begin
  Result:=TMOTPoint.Create;
  Result.Parent:=Self;
  Points.Add(Result);
end;

function TMOTFrame.LoadFromString(aStr: string): Boolean;
var
  aCol: Integer;
  aPoint: TLaserPoint;
begin
  while length(aStr)>0 do
    begin
      aPoint := Add;
      aCol := StrToInt('$'+copy(aStr,0,2));
      aStr := copy(aStr,3,length(aStr));
      case aCol of
      1:aPoint.Color := clblack;
      2:aPoint.color := clred;
      4:aPoint.color := 64592;
      8:aPoint.color := clblue;
      6:aPoint.color := clyellow;
      10:aPoint.color := clpurple;
      12:aPoint.color := claqua;
      14:aPoint.color := clwhite;
      end;
      aPoint.X := FrameMiddle - StrToInt('$'+copy(aStr,0,2))*(Parent.FrameWidth div 256);
      aStr := copy(aStr,3,length(aStr));
      aPoint.Y := FrameMiddle - StrToInt('$'+copy(aStr,0,2))*(Parent.FrameWidth div 256);
      aStr := copy(aStr,3,length(aStr));
    end;
end;

{ TMOTFrames }

constructor TMOTFrames.Create;
begin
  inherited Create;
  FSL := TStringList.Create;
end;

destructor TMOTFrames.Destroy;
begin
  FSL.Free;
end;

function TMOTFrames.Add: TLaserFrame;
begin
  Result:=TMOTFrame.Create(Self);
  Add(Result);
end;

function TMOTFrames.LoadHeaderFromStream(aStream: TStream): Boolean;
begin
  OldPointCount := 0;
  Clear;
  FPointDelay:=StrToIntDef(FSL[0],0);
  FBlankDelay:=StrToIntDef(FSL[1],0);
  NumPoints:=StrToIntDef(FSL[2],0);
end;

procedure TMOTFrames.LoadFromStream(aStream: TStream);
var
  i: Integer;
  aFrame: TMOTFrame;
  a: integer;
begin
  FSL.LoadFromStream(aStream);
  if FSL.Count<20 then exit;
  LoadHeaderFromStream(aStream);
  for i := FSL.Count-1 downto 21 do
    begin
      if TryStrToInt('$'+copy(FSL[i],0,2),a) then
        if trim(FSL[i])<>'' then
          begin
            aFrame := TMOTFrame(Add);
            aFrame.LoadfromString(FSL[i]);
          end;
    end;
end;

{
150            point delay
0            blank delay
6            number of points
100
0000000000 0        [rotate left][hor mirror][vert mirror][rotate right] ... last digit: pump
10            pic delay
1
1
1
1
360            W max
1
1
1
1
1
1
1
1
1

021C9002504802985002849002589402646C [color][x][y] - last frame
...
021C9002504802985002849002589402646C [color][x][y] - first frame
}

initialization
  FileFormats.Add('mot','Popelscan Format',TMOTFrames,[fcLoad]);

end.


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

unit uILDAFrames;

{$mode delphi}

interface

uses
  Classes, SysUtils, uLaserFrames, Graphics;

type
  { TILDAFrame }

  TILDAFrame = class(TLaserFrame)
  protected
    FFrameType : byte;
    FNumberOfEntrys : word;
  public
    CompanyName : string;
    function Add: TLaserPoint; override;
    function LoadFromStream(aStream: TStream): Boolean; override;
    procedure LoadColorPalette(aStream : TStream);
    procedure SaveToStream(aStream: TStream); override;
  end;

  { TILDAPoint }

  TILDAPoint = class(TLaserPoint)
  public
    constructor Create;override;
    function LoadFromStream(aStream: TStream): Boolean; override;
    procedure SaveToStream(aStream: TStream); override;
  end;

  { TILDAFrames }

  TILDAFrames = class(TLaserFrames)
  public
    constructor Create; override;
    function Add: TLaserFrame; overload; override;
    function LoadHeaderFromStream(aStream: TStream): Boolean;override;
    procedure SaveHeaderToStream(aStream: TStream); override;
  end;

implementation

const
  palette : array[0..256*4] of byte =
   (0,0,0,0,//Black/blanked (fixed)
    1,255,255,255,//White (fixed)
    2,255,0,0,//Red (fixed)
    3,255,255,0,//Yellow (fixed)
    4,0,255,0,//Green (fixed)
    5,0,255,255,//Cyan (fixed)
    6,0,0,255,//Blue (fixed)
    7,255,0,255,//Magenta (fixed)
    8,255,128,128,//Light red
    9,255,140,128,
    10,255,151,128,
    11,255,163,128,
    12,255,174,128,
    13,255,186,128,
    14,255,197,128,
    15,255,209,128,
    16,255,220,128,
    17,255,232,128,
    18,255,243,128,
    19,255,255,128,//Light yellow
    20,243,255,128,
    21,232,255,128,
    22,220,255,128,
    23,209,255,128,
    24,197,255,128,
    25,186,255,128,
    26,174,255,128,
    27,163,255,128,
    28,151,255,128,
    29,140,255,128,
    30,128,255,128,//Light green
    31,128,255,140,
    32,128,255,151,
    33,128,255,163,
    34,128,255,174,
    35,128,255,186,
    36,128,255,197,
    37,128,255,209,
    38,128,255,220,
    39,128,255,232,
    40,128,255,243,
    41,128,255,255,//Light cyan
    42,128,243,255,
    43,128,232,255,
    44,128,220,255,
    45,128,209,255,
    46,128,197,255,
    47,128,186,255,
    48,128,174,255,
    49,128,163,255,
    50,128,151,255,
    51,128,140,255,
    52,128,128,255,//Light blue
    53,140,128,255,
    54,151,128,255,
    55,163,128,255,
    56,174,128,255,
    57,186,128,255,
    58,197,128,255,
    59,209,128,255,
    60,220,128,255,
    61,232,128,255,
    62,243,128,255,
    63,255,128,255,//Light magenta
    64,255,128,243,
    65,255,128,232,
    66,255,128,220,
    67,255,128,209,
    68,255,128,197,
    69,255,128,186,
    70,255,128,174,
    71,255,128,163,
    72,255,128,151,
    73,255,128,140,
    74,255,0,0,//Red (cycleable)
    75,255,23,0,
    76,255,46,0,
    77,255,70,0,
    78,255,93,0,
    79,255,116,0,
    80,255,139,0,
    81,255,162,0,
    82,255,185,0,
    83,255,209,0,
    84,255,232,0,
    85,255,255,0,//Yellow (cycleable)
    86,232,255,0,
    87,209,255,0,
    88,185,255,0,
    89,162,255,0,
    90,139,255,0,
    91,116,255,0,
    92,93,255,0,
    93,70,255,0,
    94,46,255,0,
    95,23,255,0,
    96,0,255,0,//Green (cycleable)
    97,0,255,23,
    98,0,255,46,
    99,0,255,70,
    100,0,255,93,
    101,0,255,116,
    102,0,255,139,
    103,0,255,162,
    104,0,255,185,
    105,0,255,209,
    106,0,255,232,
    107,0,255,255,//Cyan (cycleable)
    108,0,232,255,
    109,0,209,255,
    110,0,185,255,
    111,0,162,255,
    112,0,139,255,
    113,0,116,255,
    114,0,93,255,
    115,0,70,255,
    116,0,46,255,
    117,0,23,255,
    118,0,0,255,//Blue (cycleable)
    119,23,0,255,
    120,46,0,255,
    121,70,0,255,
    122,93,0,255,
    123,116,0,255,
    124,139,0,255,
    125,162,0,255,
    126,185,0,255,
    127,209,0,255,
    128,232,0,255,
    129,255,0,255,//Magenta (cycleable)
    130,255,0,232,
    131,255,0,209,
    132,255,0,185,
    133,255,0,162,
    134,255,0,139,
    135,255,0,116,
    136,255,0,93,
    137,255,0,70,
    138,255,0,46,
    139,255,0,23,
    140,128,0,0,//Dark red
    141,128,12,0,
    142,128,23,0,
    143,128,35,0,
    144,128,47,0,
    145,128,58,0,
    146,128,70,0,
    147,128,81,0,
    148,128,93,0,
    149,128,105,0,
    150,128,116,0,
    151,128,128,0,//Dark yellow
    152,116,128,0,
    153,105,128,0,
    154,93,128,0,
    155,81,128,0,
    156,70,128,0,
    157,58,128,0,
    158,47,128,0,
    159,35,128,0,
    160,23,128,0,
    161,12,128,0,
    162,0,128,0,//Dark green
    163,0,128,12,
    164,0,128,23,
    165,0,128,35,
    166,0,128,47,
    167,0,128,58,
    168,0,128,70,
    169,0,128,81,
    170,0,128,93,
    171,0,128,105,
    172,0,128,116,
    173,0,128,128,//Dark cyan
    174,0,116,128,
    175,0,105,128,
    176,0,93,128,
    177,0,81,128,
    178,0,70,128,
    179,0,58,128,
    180,0,47,128,
    181,0,35,128,
    182,0,23,128,
    183,0,12,128,
    184,0,0,128,//Dark blue
    185,12,0,128,
    186,23,0,128,
    187,35,0,128,
    188,47,0,128,
    189,58,0,128,
    190,70,0,128,
    191,81,0,128,
    192,93,0,128,
    193,105,0,128,
    194,116,0,128,
    195,128,0,128,//Dark magenta
    196,128,0,116,
    197,128,0,105,
    198,128,0,93,
    199,128,0,81,
    200,128,0,70,
    201,128,0,58,
    202,128,0,47,
    203,128,0,35,
    204,128,0,23,
    205,128,0,12,
    206,255,192,192,//Very light red
    207,255,64,64,//Light-medium red
    208,192,0,0,//Medium-dark red
    209,64,0,0,//Very dark red
    210,255,255,192,//Very light yellow
    211,255,255,64,//Light-medium yellow
    212,192,192,0,//Medium-dark yellow
    213,64,64,0,//Very dark yellow
    214,192,255,192,//Very light green
    215,64,255,64,//Light-medium green
    216,0,192,0,//Medium-dark green
    217,0,64,0,//Very dark green
    218,192,255,255,//Very light cyan
    219,64,255,255,//Light-medium cyan
    220,0,192,192,//Medium-dark cyan
    221,0,64,64,//Very dark cyan
    222,192,192,255,//Very light blue
    223,64,64,255,//Light-medium blue
    224,0,0,192,//Medium-dark blue
    225,0,0,64,//Very dark blue
    226,255,192,255,//Very light magenta
    227,255,64,255,//Light-medium magenta
    228,192,0,192,//Medium-dark magenta
    229,64,0,64,//Very dark magenta
    230,255,96,96,//Medium skin tone
    231,255,255,255,//White (cycleable)
    232,245,245,245,
    233,235,235,235,
    234,224,224,224,//Very light gray (7/8 intensity)
    235,213,213,213,
    236,203,203,203,
    237,192,192,192,//Light gray (3/4 intensity)
    238,181,181,181,
    239,171,171,171,
    240,160,160,160,//Medium-light gray (5/8 int.)
    241,149,149,149,
    242,139,139,139,
    243,128,128,128,//Medium gray (1/2 intensity)
    244,117,117,117,
    245,107,107,107,
    246,96,96,96,//Medium-dark gray (3/8 int.)
    247,85,85,85,
    248,75,75,75,
    249,64,64,64,//Dark gray (1/4 intensity)
    250,53,53,53,
    251,43,43,43,
    252,32,32,32,//Very dark gray (1/8 intensity)
    253,21,21,21,
    254,11,11,11,
    255,0,0,0,0);//Black (cycleable/changeable)
{ TILDAPoint }

constructor TILDAPoint.Create;
begin
  inherited Create;
  Is3D:=False;
end;

function TILDAPoint.LoadFromStream(aStream: TStream): Boolean;
var
  status,colori : byte;
  si : SmallInt;
begin
  Result := True;
  aStream.Read(si,2);
  x := BEtoN(si)+($FFFF div 2);
  aStream.Read(si,2);
  y := (-BEtoN(si))+($FFFF div 2);
  if TILDAFrame(Parent).FFrameType = 0 then //3d Point
    begin
      aStream.Read(si,2);
      z := BEtoN(si);
      Is3D := True;
    end;
  aStream.Read(status,1);
  aStream.Read(colori,1);
  Color := RGBToColor(palette[(colori*4)+1],palette[(colori*4)+2],palette[(colori*4)+3]);
  Blanking := (Status and $40 = $40);
  Result := not (Status and $80 = $80); // Last Point
end;

procedure TILDAPoint.SaveToStream(aStream: TStream);
var
  si : SmallInt;
  b : byte;
begin
  si := NtoBE(x-Parent.FrameMiddle);
  aStream.Write(si,2);
  si := NtoBE(y-Parent.FrameMiddle);
  aStream.Write(si,2);
  si := NtoBE(z-Parent.FrameMiddle);
  aStream.Write(si,2);
  b := 0;
  if Blanking then
    b := b or $40;
  if Parent.Points.IndexOf(Self) = Parent.Points.Count-1 then
    b := b or $80;//last Point
  aStream.write(b,1);
  b := 10;
  aStream.write(b,1);//TODO:Color
end;

{ TILDAFrames }

constructor TILDAFrames.Create;
begin
  inherited Create;
end;

function TILDAFrames.Add: TLaserFrame;
begin
  Result:=TILDAFrame.Create(Self);
  Add(Result);
end;

function TILDAFrames.LoadHeaderFromStream(aStream: TStream): Boolean;
begin
  OldPointCount := 0;
  Clear;
end;

procedure TILDAFrames.SaveHeaderToStream(aStream: TStream);
begin
end;

{ TILDAFrame }

function TILDAFrame.Add: TLaserPoint;
begin
  Result:=TILDAPoint.Create;
  Result.Parent:=Self;
  Points.Add(Result);
end;

function TILDAFrame.LoadFromStream(aStream: TStream): Boolean;
var
  s1: array[1..4] of char;
  s2: array[1..8] of char;
  b : byte;
  w : word;
  aPoint: TILDAPoint;
  aEntry: Integer;
begin
  Result := True;
  if aStream.Size > 5 then
    begin
      //ILDA
      aStream.Read(s1,4);
      //Unused
      aStream.Read(b,1);
      aStream.Read(b,1);
      aStream.Read(b,1);
      //Frame Type
      aStream.Read(b,1);
      FFrameType := b;
      if not (s1 = 'ILDA') then Result := False;
    end
  else Result := False;
  if not Result then exit;
  // frame name
  aStream.Read(s2,8);
  FrameName := s2;
  aStream.Read(s2,8);
  CompanyName := s2;
  aStream.Read(w,2);
  w := BEtoN(w);
  FNumberOfEntrys := w;
  aStream.Read(w,2);//Frame Number
  w := BEtoN(w);
  aStream.Read(w,2);//Total Number of Frames
  w := BEtoN(w);
  aStream.Read(b,1);//ScannerHead
  aStream.Read(b,1);//unused
  if FFrameType=2 then//Color Palette
    LoadColorPalette(aStream)
  else if FNumberOfEntrys>0 then
    begin
      aEntry := 0;
      aPoint := TILDAPoint.Create;
      aPoint.Parent:=Self;
      Points.Add(aPoint);
      while (aPoint.LoadFromStream(aStream)) and (aEntry<FNumberOfEntrys) do
        begin
          inc(aEntry);
          aPoint := TILDAPoint.Create;
          aPoint.Parent:=Self;
          Points.Add(aPoint);
        end;
      aPoint.Free;
    end;
end;

procedure TILDAFrame.SaveToStream(aStream: TStream);
var
  sBuffer: String[8];
  b : byte;
  w : word;
  i: Integer;
begin
  sBuffer := 'ILDA';
  aStream.Write(sBuffer[1],4); //magic
  b := 0;
  aStream.Write(b,1);
  aStream.Write(b,1);
  aStream.Write(b,1);
  aStream.Write(b,1); //Frame Type always 3D
  sBuffer := FrameName;
  aStream.Write(sBuffer[1],8); //magic
  sBuffer := CompanyName;
  aStream.Write(sBuffer[1],8); //magic
  w := NtoBE(Points.Count);
  aStream.Write(w,2);
  w := NtoBE(FrameIndex);
  aStream.Write(w,2);
  w := NtoBE(Parent.Count);
  aStream.Write(w,2);
  b := 0; //TODO:Scanner Head
  aStream.Write(b,1);
  b := 0;
  aStream.Write(b,1);
  for i := 0 to Points.Count-1 do
    TILDAPoint(Points[i]).SaveToStream(aStream);
end;

procedure TILDAFrame.LoadColorPalette(aStream: TStream);
var
  b : byte;
  i: Integer;
begin
  for i := 0 to FNumberOfEntrys-1 do
    begin
      aStream.Read(b,1);//r
      aStream.Read(b,1);//g
      aStream.Read(b,1);//b
    end;
end;

initialization
  FileFormats.Add('ild','ILDA Format',TILDAFrames,[fcLoad,fcSave]);

end.

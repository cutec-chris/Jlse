unit ulasershow;

{$mode delphi}

interface

uses
  Classes, SysUtils, uLaserFrames;

type
  TShowDataItem = record
    X : word;
    Y : word;
    R : byte;
    G : byte;
    B : byte;
    Frameindex : Integer;
  end;

  TShowData = array of TShowDataItem;

  { TShow }

  TShow = class(TObject)
  private
    Data : TShowData;
    FFrames: TLaserFrames;
    FFullTime: Cardinal;
    procedure SetFrames(AValue: TLaserFrames);
  public
    property Frames : TLaserFrames read FFrames write SetFrames;
    property FullTime : Cardinal read FFullTime;
  end;

  { TShowThread }

  TShowThread = class(TThread)
  private
    Data : TShowData;
  public
    procedure Execute;override;
    constructor Create(aFrame : TLaserFrame;aShow : TShow;aIndex : Integer);
  end;

  atp = array of TPoint;
  atb = array of boolean;

var
  Time5Degree,
  Time10Degree,
  Time40Degree,
  TimeEdges : Word;

implementation

{ TShowThread }

{
procedure Stetigkeit(fromp, top: TPoint; color: boolean; blank: boolean);
var
  j: integer;
  dx, dy: integer;
  ax, ay: word;
  tx, ty, t: word;
  a: atp;
  b: atb;
begin
  dx := integer(top.x) - integer(fromp.x);
  dy := integer(top.y) - integer(fromp.y);
  if Abs(dx) < 32 then
    tx := Time5Degree
  else if Abs(dx) < 64 then
    tx := Time10Degree
  else
    tx := Time40Degree;
  if Abs(dy) < 32 then
    ty := Time5Degree
  else if Abs(dy) < 64 then
    ty := Time10Degree
  else
    ty := Time40Degree;
  if tx > ty then
    t := tx
  else
    t := ty;
  SetLength(a, t);
  SetLength(b, t);
  for j := 0 to Pred(t) do
    begin
    ax := fromp.x + Round(dx * j / t);
    ay := fromp.y + Round(dy * j / t);
    TPoint(a[j]).x := ax;
    TPoint(a[j]).y := ay;
    b[j] := blank;
    end;
  WritePointArray(TStream(ms), a, b, color, writtensamples, lastpoint);
end;

procedure DoEffect(Frame1, Frame2: TLaserFrame; forw: boolean);
var
  j, i: integer;
  subcolor: boolean;
  subcalc: real;
  a, b, c, v, dp: TPoint;
begin
  // ### effect: x-flip,y-flip,plode
  if (Frame1.Effect in [effect_plode, effect_xflip, effect_yflip]) then
    begin
    topoint.x := Frame1.RotCenter.x;
    topoint.y := Frame1.RotCenter.y;
    bx := -1;
    by := -1;
    // ### stetig: lastpoint -> topoint
    Stetigkeit(lastpoint, topoint, ((Frame1.Bits and 1) = 1), True);
    FormStatus.pgMorph.Max := iMorphSamples;
    for j := 0 to Pred(iMorphSamples div 2) do
      begin
      for i := 0 to Pred(Length(wavedata)) do
        begin
        calc := (j + ((i + 1) / Length(wavedata))) / (iMorphSamples div 2);
        if Frame1.EffectParam = 0 then
          begin
          if not forw then
            calc := 1 - calc;
          end
        else
          begin
          if forw then
            calc := sin(calc * Pi / 2)
          else
            calc := cos(calc * Pi / 2);
          end;
        if Frame1.Effect in [effect_yflip, effect_plode] then
          bx := Round((TPoint(wavedata[i]).x - Frame1.RotCenter.x) *
            calc + Frame1.RotCenter.x)
        else
          bx := TPoint(wavedata[i]).x;
        if Frame1.Effect in [effect_xflip, effect_plode] then
          by := Round((TPoint(wavedata[i]).y - Frame1.RotCenter.y) *
            calc + Frame1.RotCenter.y)
        else
          by := TPoint(wavedata[i]).y;
        subcolor := ((Frame2.Bits and 1) = 1);
        WritePoints(TStream(ms), bx + 128, by + 128, subcolor, False); //##
        Inc(writtensamples);
        end;
      end;
    end
  else if (Frame1.Effect in [effect_dflip]) then
    begin
    a := Frame1.RotCenter;
    b.x := Frame1.RotCenter.x - Frame1.AuxCenter.x;
    b.y := Frame1.RotCenter.y - Frame1.AuxCenter.y;
    // topoint errechnen
    if Length(wavedata) > 0 then
      begin
      calc := 0;
      if forw then
        calc := 1 - calc;
      c := wavedata[0];
      subcalc := (((c.x - a.x) * b.x) + ((c.y - a.y) * b.y)) / (Sqr(b.x) + Sqr(b.y));
      v.x := a.x + Round(subcalc * b.x);
      v.y := a.y + Round(subcalc * b.y);
      dp.x := v.x - c.x;
      dp.y := v.y - c.y;
      c.x := c.x + Round(calc * dp.x);
      c.y := c.y + Round(calc * dp.y);
      if c.x > 255 then
        c.x := 255;
      if c.x < 0 then
        c.x := 0;
      if c.y > 255 then
        c.y := 255;
      if c.y < 0 then
        c.y := 0;
      bx := c.x;
      by := c.y;
      topoint := c;
      end;
    // ### stetig: lastpoint -> topoint
    Stetigkeit(lastpoint, topoint, ((Frame1.Bits and 1) = 1), True);
    FormStatus.pgMorph.Max := iMorphSamples;
    for j := 0 to Pred(iMorphSamples div 2) do
      begin
      for i := 0 to Pred(Length(wavedata)) do
        begin
        calc := (j + ((i + 1) / Length(wavedata))) / (iMorphSamples div 2);
        if forw then
          calc := 1 - calc;
        c := wavedata[i];
        subcalc := (((c.x - a.x) * b.x) + ((c.y - a.y) * b.y)) / (Sqr(b.x) + Sqr(b.y));
        v.x := a.x + Round(subcalc * b.x);
        v.y := a.y + Round(subcalc * b.y);
        dp.x := v.x - c.x;
        dp.y := v.y - c.y;
        c.x := c.x + Round(calc * dp.x);
        c.y := c.y + Round(calc * dp.y);
        if c.x > 255 then
          c.x := 255;
        if c.x < 0 then
          c.x := 0;
        if c.y > 255 then
          c.y := 255;
        if c.y < 0 then
          c.y := 0;
        bx := c.x;
        by := c.y;
        subcolor := ((Frame2.Bits and 1) = 1);
        WritePoints(TStream(ms), bx + 128, by + 128, subcolor, False); //##
        Inc(writtensamples);
        end;
      if forw then
        FormStatus.pgMorph.Position := j
      else
        FormStatus.pgMorph.Position := (FormStatus.pgMorph.Max + j);
      FormStatus.pgTotal.Position := iTimeDone + (Frame1.Morph * j div iMorphSamples);
      FormStatus.Repaint;
      end;
    end
  else if (Frame1.Effect in [effect_rotate, effect_drain]) then
    begin
    // ### effect: rotate
    bx := -1;
    by := -1;
    if Length(wavedata) > 0 then
      begin
      if Frame1.Effect = effect_drain then
        begin
        topoint.x := Frame1.RotCenter.x;
        topoint.y := Frame1.RotCenter.y;
        end
      else
        begin
        winkel := Frame1.EffectParam * Pi / 180;
        topoint.x := (TPoint(wavedata[0]).x - Frame1.RotCenter.x);
        topoint.y := (TPoint(wavedata[0]).y - Frame1.RotCenter.y);
        pw := arg(topoint.x, topoint.y) + winkel;
        radius := Sqrt(Sqr(topoint.x) + Sqr(topoint.y));
        topoint.x := Round(radius * Cos(pw)) + Frame1.RotCenter.x;
        if topoint.x < 0 then
          topoint.x := 0;
        if topoint.x > 255 then
          topoint.x := 255;
        topoint.y := Round(radius * Sin(pw)) + Frame1.RotCenter.y;
        if topoint.y < 0 then
          topoint.y := 0;
        if topoint.y > 255 then
          topoint.y := 255;
        end;
      Stetigkeit(lastpoint, topoint, ((Frame1.Bits and 1) = 1), True);
      end;
    FormStatus.pgMorph.Max := iMorphSamples;
    for j := 0 to Pred(iMorphSamples div 2) do
      begin
      for i := 0 to Pred(Length(wavedata)) do
        begin
        calc := 1 - ((j + ((i + 1) / Length(wavedata))) / (iMorphSamples div 2));
        subcalc := (j + ((i + 1) / Length(wavedata))) / (iMorphSamples div 2);
        if not forw then
          calc := 1 - calc;
        if not forw then
          subcalc := 1 - subcalc;
        winkel := Frame1.EffectParam * Pi * calc / 180;
        if not forw then
          winkel := -winkel;
        bx := (TPoint(wavedata[i]).x - Frame1.RotCenter.x);
        by := (TPoint(wavedata[i]).y - Frame1.RotCenter.y);
        pw := arg(bx, by) + winkel;
        radius := Sqrt(Sqr(bx) + Sqr(by));
        bx := Round(radius * Cos(pw)) + Frame1.RotCenter.x;
        by := Round(radius * Sin(pw)) + Frame1.RotCenter.y;
        if Frame1.Effect = effect_drain then
          begin
          bx := Round((bx - Frame1.RotCenter.x) * subcalc) + Frame1.RotCenter.x;
          by := Round((by - Frame1.RotCenter.y) * subcalc) + Frame1.RotCenter.y;
          end;
        //if bx<0 then bx := 0; if bx>255 then bx := 255;
        //if by<0 then by := 0; if by>255 then by := 255;
        if bx < 1 then
          bx := 1;
        if bx > 254 then
          bx := 254;
        if by < 1 then
          by := 1;
        if by > 254 then
          by := 254;
        //### sollte nicht so sein, aber was solls
        subcolor := ((Frame2.Bits and 1) = 1);
        WritePoints(TStream(ms), bx + 128, by + 128, subcolor, False);
        Inc(writtensamples);
        end;
      if Frame1.Effect = effect_drain then
        FormStatus.pgMorph.Position := j
      else
        begin
        if forw then
          FormStatus.pgMorph.Position := j
        else
          FormStatus.pgMorph.Position := (FormStatus.pgMorph.Max + j);
        end;
      FormStatus.pgTotal.Position := iTimeDone + (Frame1.Morph * j div iMorphSamples);
      FormStatus.Repaint;
      end;
    end;
  // ### special effect: morph last frame into this!!! ################
  if (Frame1.Effect = effect_morph) and (framecounter > 0) and forw then
    begin
    mypf := FFile.frames[Pred(framecounter)];
    // ### stetig: lastpoint -> topoint
    topoint.x := TLaserPoint(mypf.Points[0]).x;
    topoint.y := TLaserPoint(mypf.Points[0]).y;
    Stetigkeit(lastpoint, topoint, ((Frame1.Bits and 1) = 1), True);
    iMorphDuration := 0;
    iMorphSamples := Frame1.Morph * 44100 div 1000;
    FormStatus.pgMorph.Max := iMorphSamples;
    dummyp := nil;
    while (iMorphDuration < iMorphSamples) do
      begin
      frameDummy := TLaserFrame.Create(myf.Parent);
        try
        for i := 0 to Pred(mypf.Points.Count) do
          begin
          calc := iMorphDuration / iMorphSamples;
          if calc > 1 then
            calc := 1;
          for j := 0 to Pred(myf.Points.Count) do
            begin
            if Frame1.links[j, i] then
              begin
              myp := Frame1.Points[j];
              mypp := mypf.Points[i];
              dummyp := TLaserPoint.Create;
              dummyp.x := mypp.x + (Round((myp.x - mypp.x) * calc));
              dummyp.y := mypp.y + (Round((myp.y - mypp.y) * calc));
              dummyp.bits := mypp.bits;
              frameDummy.Points.add(dummyp);
              end;
            end;
          end;
        FrameToArray(frameDummy, morphdata, morphblank, iMorphDuration);
        finally
        FreeAndNil(frameDummy);
        end;
      if iMorphDuration < iMorphSamples then
        FormStatus.pgMorph.Position := iMorphDuration;
      FormStatus.pgTotal.Position := iTimeDone + Round(Frame1.Morph * calc);
      FormStatus.Repaint;
      end;
    if dummyp <> nil then
      begin
      lastpoint.x := dummyp.x;
      lastpoint.y := dummyp.y;
      end;
    WritePointArray(TStream(ms), morphdata, morphblank,
      ((mypf.Bits and 1) = 1), writtensamples, lastpoint);
    end;
  Inc(iTimeDone, Frame1.Morph div 2);
  if bx > -1 then
    lastpoint.x := bx;
  if by > -1 then
    lastpoint.y := by;
end;
}

procedure TShowThread.Execute;
var
  i, j: integer;
  p, np, pp: TLaserPoint;
  dx, dy: integer;
  ax, ay: word;
  tx, ty, t, tsub: word;
  wp1, wp2: TPoint;
  mywinkel: real;
begin
  for i := 0 to Pred(f.Points.Count) do
    begin
      p := f.Points[i];
      if (i < (Pred(f.Points.Count))) then
        np := f.Points[i + 1]
      else
        np := f.Points[0];
      if (i > 0) then
        pp := f.Points[Pred(i)]
      else
        pp := f.Points[Pred(f.Points.Count)];
      dx := integer(np.x) - integer(p.x);
      dy := integer(np.y) - integer(p.y);
      if Abs(dx) < 32 then
        tx := Time5Degree
      else if Abs(dx) < 64 then
        tx := Time10Degree
      else
        tx := Time40Degree;
      if Abs(dy) < 32 then
        ty := Time5Degree
      else if Abs(dy) < 64 then
        ty := Time10Degree
      else
        ty := Time40Degree;
      if tx > ty then
        t := tx
      else
        t := ty;
      if ((p.bits and 1) = 1) then
        begin // vorher nach naechster schleife
          wp1.x := integer(p.x) - integer(pp.x);
          wp1.y := integer(p.y) - integer(pp.y);
          wp2.x := integer(np.x) - integer(p.x);
          wp2.y := integer(np.y) - integer(p.y);
          mywinkel := Abs(arg(wp2.x, wp2.y) - arg(wp1.x, wp1.y));
          tsub := Round(TimeEdges * 2 * (mywinkel / Pi));
          Inc(framed, tsub);
          SetLength(mya, framed);
          SetLength(myb, framed);
          for j := 0 to Pred(tsub) do
            begin
              TPoint(mya[framed - tsub + j]).x := p.x; // vorher np
              TPoint(mya[framed - tsub + j]).y := p.y; // vorher np
              myb[framed - tsub + j] := (p.bits and 2) = 2;
            end;
        end;
      Inc(framed, t);
      SetLength(mya, framed);
      SetLength(myb, framed);
      for j := 0 to Pred(t) do
        begin
          ax := p.x + Round(dx * j / t);
          ay := p.y + Round(dy * j / t);
          TPoint(mya[framed - t + j]).x := ax;
          TPoint(mya[framed - t + j]).y := ay;
          myb[framed - t + j] := (p.bits and 2) = 2;
        end;
    end; // end framework
end;

constructor TShowThread.Create(aFrame: TLaserFrame; aShow: TShow;
  aIndex: Integer);
begin
  inherited Create(False);

end;

procedure TShow.SetFrames(AValue: TLaserFrames);
var
  framecounter: Integer;
begin
  if FFrames=AValue then Exit;
  FFrames:=AValue;
  for framecounter := 0 to Pred(FFrames.Count) do
    begin
      Inc(FFullTime, TLaserFrame(FFrames.Frames[framecounter]).Delay);
      Inc(FFullTime, TLaserFrame(FFrames.Frames[framecounter]).Morph);
    end;
end;

end.


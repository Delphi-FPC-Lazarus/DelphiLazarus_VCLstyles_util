{
  VCL Style Utils

  02/2016 XE10 x64 Test

  --------------------------------------------------------------------
  This Source Code Form is subject to the terms of the Mozilla Public
  License, v. 2.0. If a copy of the MPL was not distributed with this
  file, You can obtain one at https://mozilla.org/MPL/2.0/.

  THE SOFTWARE IS PROVIDED "AS IS" AND WITHOUT WARRANTY

  Author: Peter Lorenz
  Is that code useful for you? Donate!
  Paypal webmaster@peter-ebe.de
  --------------------------------------------------------------------


}

{$I ..\share_settings.inc}
unit VclStyleUtil;

interface

Uses
{$IFDEF FPC}
{$IFNDEF UNIX}Windows, {$ENDIF}
  Messages, SysUtils, Variants, Classes, Graphics,
  Controls, Forms, Dialogs, StdCtrls, ExtCtrls;
{$ELSE}
Winapi.Windows,
  System.Types,
  System.SysUtils,
  System.Classes,
  Vcl.Dialogs,
  Vcl.Themes,
  Vcl.Styles,
  Vcl.Forms,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,
  Vcl.Buttons;
{$ENDIF}
function GetStyleBgColor: TColor;
function GetStyleTextGlypColor: TColor;

procedure StyleChangeGlyph(ABitmap: TBitmap);
procedure StyleChangeSpeedButtonGlyph(AButton: TSpeedButton);

procedure StyleChangeGlyphs(AForm: TForm);

implementation

const
  cimgtag = 9999;

  // --------------------------------------------------------------------------

function GetStyleBgColor: TColor;
begin
  Result := StyleServices.GetStyleColor(scButtonNormal);
end;

// --------------------------------------------------------------------------

function GetStyleTextGlypColor: TColor;
var
  LDetails: TThemedElementDetails;
  LColor: TColor;
begin
  Result := clBlack;

  LDetails := TStyleManager.ActiveStyle.GetElementDetails(tbPushButtonNormal);
  TStyleManager.ActiveStyle.GetElementColor(LDetails, ecTextColor, LColor);
  Result := LColor;
end;

// --------------------------------------------------------------------------

function RGB2TColor(const R, G, B: Byte): Integer;
begin
  Result := R + G shl 8 + B shl 16;
end;

procedure TColor2RGB(const Color: TColor; var R, G, B: Byte);
begin
  R := Color and $FF;
  G := (Color shr 8) and $FF;
  B := (Color shr 16) and $FF;
end;

procedure StyleChangeGlyph(ABitmap: TBitmap);
type
  RT = array [0 .. 1024] of TRGBQuad;
  RP = ^RT;
var
  X: Integer;
  Y: Integer;
  P: RP;
  C: TColor;
  R, G, B: Byte;
begin
  if not Assigned(ABitmap) then
    exit;
  if ABitmap.Empty then
    exit;
  if ABitmap.Width > High(RT) + 1 then
    exit;

  ABitmap.PixelFormat := pf32bit;
  C := GetStyleTextGlypColor;
  TColor2RGB(C, R, G, B);
  if R > 254 then
    R := 254;
  if G > 254 then
    G := 254;
  if B > 254 then
    B := 254;
  for Y := 1 to ABitmap.Height do
  begin
    P := ABitmap.ScanLine[Y - 1];
    for X := 1 to ABitmap.Width do
    begin
      if (P^[X - 1].rgbBlue < 255) and (P^[X - 1].rgbGreen < 255) and
        (P^[X - 1].rgbRed < 255) then
      begin
        P^[X - 1].rgbBlue := B;
        P^[X - 1].rgbGreen := G;
        P^[X - 1].rgbRed := R;
        // P^[X-1].rgbReserved
      end;
    end;
  end;
end;

// --------------------------------------------------------------------------

procedure StyleChangeSpeedButtonGlyph(AButton: TSpeedButton);
var
  ABmp: TBitmap;
begin
  if not Assigned(AButton.Glyph) then
    exit;
  if AButton.Glyph.Empty then
    exit;

  ABmp := nil;
  try
    ABmp := TBitmap.create;
    ABmp.Assign(AButton.Glyph);
    StyleChangeGlyph(ABmp);
    ABmp.PixelFormat := pf24bit;
    AButton.Glyph := ABmp;
  finally
    FreeAndNil(ABmp);
  end;
end;

// --------------------------------------------------------------------------

procedure StyleChangeGlyphs(AForm: TForm);

  procedure DoChange(AComp: TComponent);
  var
    i: Integer;
  begin
    // SpeedButtton
    if AComp is TSpeedButton then
      if Assigned(TSpeedButton(AComp).Glyph) then
        if not TSpeedButton(AComp).Glyph.Empty then
          StyleChangeSpeedButtonGlyph(TSpeedButton(AComp));

    // Image (nur wenn Tag gesetzt!)
    if AComp is TImage then
      if Assigned(TImage(AComp).Picture.Bitmap) then
        if not TImage(AComp).Picture.Bitmap.Empty then
          if AComp.Tag = cimgtag then
            StyleChangeGlyph(TImage(AComp).Picture.Bitmap);

    // Recursiver Aufruf für Container
    if AComp.ComponentCount > 0 then
    begin
      for i := 1 to AComp.ComponentCount do
        DoChange(AComp.Components[i - 1]);
    end;
  end;

begin
  DoChange(AForm);
end;

// --------------------------------------------------------------------------

end.

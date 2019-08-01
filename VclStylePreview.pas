{
  VCL Style Vorschau

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
unit VclStylePreview;

interface

uses
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
  Vcl.ExtCtrls;
{$ENDIF}

type
  TVclStylesPreview = class(TCustomControl)
  private
    FStyle: TCustomStyleServices;
    FIcon: HICON;
    FCaption: TCaption;
    FRegion: HRGN;
    FBitmap: TBitmap;
  protected
    procedure Paint; override;
  public
    property Icon: HICON read FIcon Write FIcon;
    property Style: TCustomStyleServices read FStyle Write FStyle;
    property Caption: TCaption read FCaption write FCaption;
    property BitMap: TBitmap read FBitmap write FBitmap;
    constructor Create(AControl: TComponent); override;
    destructor Destroy; override;
  end;

implementation

constructor TVclStylesPreview.Create(AControl: TComponent);
begin
  inherited;
  FRegion := 0;
  FStyle := nil;
  FCaption := '';
  FIcon := 0;
  FBitmap := TBitmap.Create;
  FBitmap.PixelFormat := pf32bit;
end;

destructor TVclStylesPreview.Destroy;
begin
  if FRegion <> 0 then
  begin
    DeleteObject(FRegion);
    FRegion := 0;
  end;
  FBitmap.Free;
  inherited;
end;

procedure TVclStylesPreview.Paint;
var
  LDetails: TThemedElementDetails;
  CaptionDetails: TThemedElementDetails;
  IconDetails: TThemedElementDetails;
  IconRect: TRect;
  BorderRect: TRect;
  CaptionRect: TRect;
  ButtonRect: TRect;
  TextRect: TRect;
  CaptionBitmap: TBitmap;
  ThemeTextColor: TColor;
  ARect: TRect;
  LRegion: HRGN;

  function GetBorderSize: TRect;
  var
    Size: TSize;
    Details: TThemedElementDetails;
    Detail: TThemedWindow;
  begin
    Result := Rect(0, 0, 0, 0);
    Detail := twCaptionActive;
    Details := FStyle.GetElementDetails(Detail);
    FStyle.GetElementSize(0, Details, esActual, Size);
    Result.Top := Size.cy;
    Detail := twFrameLeftActive;
    Details := FStyle.GetElementDetails(Detail);
    FStyle.GetElementSize(0, Details, esActual, Size);
    Result.Left := Size.cx;
    Detail := twFrameRightActive;
    Details := FStyle.GetElementDetails(Detail);
    FStyle.GetElementSize(0, Details, esActual, Size);
    Result.Right := Size.cx;
    Detail := twFrameBottomActive;
    Details := FStyle.GetElementDetails(Detail);
    FStyle.GetElementSize(0, Details, esActual, Size);
    Result.Bottom := Size.cy;
  end;

  function RectVCenter(var R: TRect; Bounds: TRect): TRect;
  begin
    OffsetRect(R, -R.Left, -R.Top);
    OffsetRect(R, 0, (Bounds.Height - R.Height) div 2);
    OffsetRect(R, Bounds.Left, Bounds.Top);
    Result := R;
  end;

begin
  if FStyle = nil then
    Exit;

  BorderRect := GetBorderSize;
  ARect := ClientRect;

  FBitmap.Width := ClientRect.Width;
  FBitmap.Height := ClientRect.Height;

  if lowercase(trim(FStyle.Name)) = 'windows' then
  begin
    ButtonRect.Left := 20;
    ButtonRect.Top := 50;
    ButtonRect.Width := 75;
    ButtonRect.Height := 25;
    FBitmap.Canvas.Font.Size := 10;
    FBitmap.Canvas.TextOut(0, 0, '(Windowsoberfläche, keine Vorschau)');
    // FStyle.GetElementColor(LDetails, ecTextColor, ThemeTextColor);
    // FStyle.DrawText(FBitmap.Canvas.Handle, LDetails, 'Windowsoberfläche, keine Vorschau', ButtonRect, TTextFormatFlags(DT_VCENTER or DT_CENTER), ThemeTextColor);
  end
  else
  begin

    // Caption
    CaptionBitmap := TBitmap.Create;
    try
      CaptionBitmap.SetSize(ARect.Width, BorderRect.Top);

      // Hintergrund
      LDetails.Element := teWindow;
      LDetails.Part := 0;
      FStyle.DrawElement(FBitmap.Canvas.Handle, LDetails, ARect);

      // Caption
      CaptionRect := Rect(0, 0, CaptionBitmap.Width, CaptionBitmap.Height);
      LDetails := FStyle.GetElementDetails(twCaptionActive);

      LRegion := FRegion;
      try
        FStyle.GetElementRegion(LDetails, ARect, FRegion);
        SetWindowRgn(Handle, FRegion, True);
      finally
        if LRegion <> 0 then
          DeleteObject(LRegion);
      end;

      FStyle.DrawElement(CaptionBitmap.Canvas.Handle, LDetails, CaptionRect);
      TextRect := CaptionRect;
      CaptionDetails := LDetails;

      // Icon
      IconDetails := FStyle.GetElementDetails(twSysButtonNormal);
      if not FStyle.GetElementContentRect(0, IconDetails, CaptionRect,
        ButtonRect) then
        ButtonRect := Rect(0, 0, 0, 0);
      IconRect := Rect(0, 0, GetSystemMetrics(SM_CXSMICON),
        GetSystemMetrics(SM_CYSMICON));
      RectVCenter(IconRect, ButtonRect);
      if ButtonRect.Width > 0 then

        if FIcon <> 0 then
          DrawIconEx(CaptionBitmap.Canvas.Handle, IconRect.Left, IconRect.Top,
            FIcon, 0, 0, 0, 0, DI_NORMAL);

      Inc(TextRect.Left, ButtonRect.Width + 5);

      // Button Schließen
      LDetails := FStyle.GetElementDetails(twCloseButtonNormal);
      if FStyle.GetElementContentRect(0, LDetails, CaptionRect, ButtonRect) then
        FStyle.DrawElement(CaptionBitmap.Canvas.Handle, LDetails, ButtonRect);

      // Button Maximieren
      LDetails := FStyle.GetElementDetails(twMaxButtonNormal);
      if FStyle.GetElementContentRect(0, LDetails, CaptionRect, ButtonRect) then
        FStyle.DrawElement(CaptionBitmap.Canvas.Handle, LDetails, ButtonRect);

      // Button Minimieren
      LDetails := FStyle.GetElementDetails(twMinButtonNormal);

      if FStyle.GetElementContentRect(0, LDetails, CaptionRect, ButtonRect) then
        FStyle.DrawElement(CaptionBitmap.Canvas.Handle, LDetails, ButtonRect);

      if ButtonRect.Left > 0 then
        TextRect.Right := ButtonRect.Left;

      // Text
      FStyle.DrawText(CaptionBitmap.Canvas.Handle, CaptionDetails, FCaption,
        TextRect, [tfLeft, tfSingleLine, tfVerticalCenter]);

      // Caption zeichnen
      FBitmap.Canvas.Draw(0, 0, CaptionBitmap);

    finally
      CaptionBitmap.Free;
    end;

    // Rand links
    CaptionRect := Rect(0, BorderRect.Top, BorderRect.Left,
      ARect.Height - BorderRect.Bottom);
    LDetails := FStyle.GetElementDetails(twFrameLeftActive);
    if CaptionRect.Bottom - CaptionRect.Top > 0 then
      FStyle.DrawElement(FBitmap.Canvas.Handle, LDetails, CaptionRect);

    // Rand rechts
    CaptionRect := Rect(ARect.Width - BorderRect.Right, BorderRect.Top,
      ARect.Width, ARect.Height - BorderRect.Bottom);
    LDetails := FStyle.GetElementDetails(twFrameRightActive);
    FStyle.DrawElement(FBitmap.Canvas.Handle, LDetails, CaptionRect);

    // Rand unten
    CaptionRect := Rect(0, ARect.Height - BorderRect.Bottom, ARect.Width,
      ARect.Height);
    LDetails := FStyle.GetElementDetails(twFrameBottomActive);
    FStyle.DrawElement(FBitmap.Canvas.Handle, LDetails, CaptionRect);

    // Element Button
    LDetails := FStyle.GetElementDetails(tbPushButtonNormal);
    ButtonRect.Left := 20;
    ButtonRect.Top := 50;
    ButtonRect.Width := 75;
    ButtonRect.Height := 25;
    FStyle.DrawElement(FBitmap.Canvas.Handle, LDetails, ButtonRect);

    FStyle.GetElementColor(LDetails, ecTextColor, ThemeTextColor);
    FStyle.DrawText(FBitmap.Canvas.Handle, LDetails, 'Button', ButtonRect,
      TTextFormatFlags(DT_VCENTER or DT_CENTER), ThemeTextColor);

    // Element CheckBox
    LDetails := FStyle.GetElementDetails(tbCheckBoxCheckedNormal);
    ButtonRect.Left := 100;
    ButtonRect.Top := 50;
    ButtonRect.Width := 75;
    ButtonRect.Height := 25;
    FStyle.DrawElement(FBitmap.Canvas.Handle, LDetails, ButtonRect);

    ButtonRect.Left := 140;
    ButtonRect.Top := 52;
    ButtonRect.Width := 75;
    ButtonRect.Height := 25;
    FStyle.GetElementColor(LDetails, ecTextColor, ThemeTextColor);
    FStyle.DrawText(FBitmap.Canvas.Handle, LDetails, 'Checkbox', ButtonRect,
      TTextFormatFlags(DT_VCENTER or DT_CENTER), ThemeTextColor);

    // Element Eingabe
    LDetails := FStyle.GetElementDetails(teEditTextNormal);
    ButtonRect.Left := 20;
    ButtonRect.Top := 80;
    ButtonRect.Width := 200;
    ButtonRect.Height := 25;
    FStyle.DrawElement(FBitmap.Canvas.Handle, LDetails, ButtonRect);

    ButtonRect.Left := 25;

    FStyle.GetElementColor(LDetails, ecTextColor, ThemeTextColor);
    FStyle.DrawText(FBitmap.Canvas.Handle, LDetails, 'Eingabe/Auswahl',
      ButtonRect, TTextFormatFlags(DT_VCENTER), ThemeTextColor);

    LDetails := FStyle.GetElementDetails(tcDropDownButtonNormal);
    ButtonRect.Left := 20 + 200 - 23;
    ButtonRect.Top := 80 + 2;
    ButtonRect.Width := 25 - 4;
    ButtonRect.Height := 25 - 4;
    FStyle.DrawElement(FBitmap.Canvas.Handle, LDetails, ButtonRect);
  end;

  Canvas.Draw(0, 0, FBitmap);
end;

end.

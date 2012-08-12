unit UI;

interface

procedure Init;
procedure Render;
procedure Update;

procedure OpenBag;
procedure OpenStat;
procedure SaveStat;
procedure OpenMiniMap;
procedure OpenHUD;

procedure SwitchDebug;

procedure IncPlayerEP;
procedure DecPlayerEP;

procedure IncPlayerVP;
procedure DecPlayerVP;

procedure IncPlayerDP;
procedure DecPlayerDP;

procedure RenderMinimap( scale : Byte );
procedure RenderHUD;

implementation

uses
  System.SysUtils,

  DGLE2,
  DGLE2_types,

  SubSystems,
  Settings,
  Resources,
  Input,
  Convert,
  Game,
  Creature.Mob,
  Map,
  Runeword,

  UI.Component,
  UI.Window,
  UI.Panel,
  UI.Button,
  UI.Grid,
  UI.Caption,
  UI.Image;

var
  GUIform : TGUIPack;

  ShowMinimap : Boolean;
  ShowHUD : Boolean = True;

  buf_ep : ShortInt;
  buf_vp : ShortInt;
  buf_dp : ShortInt;
  buf_sp : ShortInt;

procedure Init;
var
  i: Integer;
begin
  {$REGION ' wnd_bag '}
    i := GUIform.Add;
         GUIform.Item[ i ] := TWindow.Create;
         GUIform.Item[ i ].name := 'wnd_bag';
         GUIform.Item[ i ].x := Window.Width-400;
         GUIform.Item[ i ].y := 0;
         GUIform.Item[ i ].w := 400;
         GUIform.Item[ i ].h := 600;
  {$ENDREGION}

    {$REGION ' pnl_bag '}
    i := GUIform.Add;
         GUIform.Item[ i ] := TPanel.Create;
         GUIform.Item[ i ].name := 'pnl_bag';
         GUIform.Item[ i ].x := 5;
         GUIform.Item[ i ].y := 360;
         GUIform.Item[ i ].w := 390;
         GUIform.Item[ i ].h := 200;
    {$ENDREGION}

      {$REGION ' grd_bag '}
      i := GUIform.Add;
           GUIform.Item[ i ] := TGrid.Create( 6, 3 );
           GUIform.Item[ i ].name := 'grd_bag';
          (GUIform.Item[ i ] as TGrid).size.x := 60;
          (GUIform.Item[ i ] as TGrid).size.y := 60;
           GUIform.Item[ i ].x := 4;
           GUIform.Item[ i ].y := 4;
           GUIform.Item[ i ].w := 376;
           GUIform.Item[ i ].h := 184;
      {$ENDREGION}

    {$REGION ' pnl_rune '}
    i := GUIform.Add;
         GUIform.Item[ i ] := TPanel.Create;
         GUIform.Item[ i ].name := 'pnl_rune';
         GUIform.Item[ i ].x := 8;
         GUIform.Item[ i ].y := 21;
         GUIform.Item[ i ].w := 384;
         GUIform.Item[ i ].h := 335;
    {$ENDREGION}

      {$REGION ' grd_rune '}
      i := GUIform.Add;
           GUIform.Item[ i ] := TGrid.Create( 3, 3 );
           GUIform.Item[ i ].name := 'grd_rune';
          (GUIform.Item[ i ] as TGrid).size.x := 96;
          (GUIform.Item[ i ] as TGrid).size.y := 96;
           GUIform.Item[ i ].x := 8;
           GUIform.Item[ i ].y := 8;
           GUIform.Item[ i ].w := 376;
           GUIform.Item[ i ].h := 319;
      {$ENDREGION}

    {$REGION ' btn_bag_ok '}
    i := GUIform.Add;
         GUIform.Item[ i ] := TButton.Create;
         GUIform.Item[ i ].name := 'btn_bag_ok';
         GUIform.Item[ i ].x := 315;
         GUIform.Item[ i ].y := 565;
         GUIform.Item[ i ].w := 77;
         GUIform.Item[ i ].h := 26;
        (GUIform.Item[ i ] as TButton).caption := 'Close';
        (GUIform.Item[ i ] as TButton).onLeftClick := OpenBag;
        (GUIform.Item[ i ] as TButton).img := txt_pack_GUI.Find('button');
        (GUIform.Item[ i ] as TButton).img_f := txt_pack_GUI.Find('button_f');
     {$ENDREGION}

    {$REGION ' cpt_gold '}
    i := GUIform.Add;
         GUIform.Item[ i ] := TCaption.Create;
         GUIform.Item[ i ].name := 'cpt_gold';
         GUIform.Item[ i ].x := 230;
         GUIform.Item[ i ].y := 565;
         GUIform.Item[ i ].w := 77;
         GUIform.Item[ i ].h := 26;
        (GUIform.Item[ i ] as TCaption).text := IntToStr( player.bag.gold );
        (GUIform.Item[ i ] as TCaption).font := 'Centaur';
        (GUIform.Item[ i ] as TCaption).size := 10;
        (GUIform.Item[ i ] as TCaption).color := Color4;
        (GUIform.Item[ i ] as TCaption).shadow := true;
        (GUIform.Item[ i ] as TCaption).align := Right;
    {$ENDREGION}

  {$REGION ' wnd_stat '}
  i := GUIform.Add;
       GUIform.Item[ i ] := TWindow.Create;
       GUIform.Item[ i ].name := 'wnd_stat';
       GUIform.Item[ i ].x := 0;
       GUIform.Item[ i ].y := 0;
       GUIform.Item[ i ].w := 400;
       GUIform.Item[ i ].h := 600;
  {$ENDREGION}

    {$REGION ' pnl_stat '}
    i := GUIform.Add;
         GUIform.Item[ i ] := TPanel.Create;
         GUIform.Item[ i ].name := 'pnl_stat';
         GUIform.Item[ i ].x := 8;
         GUIform.Item[ i ].y := 21;
         GUIform.Item[ i ].w := 384;
         GUIform.Item[ i ].h := 335;
    {$ENDREGION}

      {$REGION ' cpt_stat_name '}
      i := GUIform.Add;
           GUIform.Item[ i ] := TCaption.Create;
           GUIform.Item[ i ].name := 'cpt_stat_name';
           GUIform.Item[ i ].x := 0;
           GUIform.Item[ i ].y := 2;
           GUIform.Item[ i ].w := 384;
           GUIform.Item[ i ].h := 26;
          (GUIform.Item[ i ] as TCaption).text := player.name;
          (GUIform.Item[ i ] as TCaption).font := 'Lineage';
          (GUIform.Item[ i ] as TCaption).size := 17;
          (GUIform.Item[ i ] as TCaption).color := Color4($d4b994);
          (GUIform.Item[ i ] as TCaption).shadow := true;
          (GUIform.Item[ i ] as TCaption).align := Center;
      {$ENDREGION}

      {$REGION ' img_stat_avatar '}
      i := GUIform.Add;
           GUIform.Item[ i ] := TImage.Create;
           GUIform.Item[ i ].name := 'img_stat_avatar';
           GUIform.Item[ i ].x := 16;
           GUIform.Item[ i ].y := 28;
           GUIform.Item[ i ].w := 64;
           GUIform.Item[ i ].h := 64;
          (GUIform.Item[ i ] as TImage).image := txt_pack_GUI.Find('pict');
      {$ENDREGION}

        {$REGION ' cpt_stat_health '}
        i := GUIform.Add;
             GUIform.Item[ i ] := TCaption.Create;
             GUIform.Item[ i ].name := 'cpt_stat_health';
             GUIform.Item[ i ].x := 68;
             GUIform.Item[ i ].y := 1;
             GUIform.Item[ i ].w := 77;
             GUIform.Item[ i ].h := 21;
            (GUIform.Item[ i ] as TCaption).text := 'Health';
            (GUIform.Item[ i ] as TCaption).font := 'Centaur';
            (GUIform.Item[ i ] as TCaption).size := 12;
            (GUIform.Item[ i ] as TCaption).color := Color4($713231);
            (GUIform.Item[ i ] as TCaption).shadow := true;
            (GUIform.Item[ i ] as TCaption).align := Left;
        {$ENDREGION}

        {$REGION ' cpt_stat_mana '}
        i := GUIform.Add;
             GUIform.Item[ i ] := TCaption.Create;
             GUIform.Item[ i ].name := 'cpt_stat_mana';
             GUIform.Item[ i ].x := 68;
             GUIform.Item[ i ].y := 22;
             GUIform.Item[ i ].w := 77;
             GUIform.Item[ i ].h := 21;
            (GUIform.Item[ i ] as TCaption).text := 'Mana';
            (GUIform.Item[ i ] as TCaption).font := 'Centaur';
            (GUIform.Item[ i ] as TCaption).size := 12;
            (GUIform.Item[ i ] as TCaption).color := Color4($6081a1);
            (GUIform.Item[ i ] as TCaption).shadow := true;
            (GUIform.Item[ i ] as TCaption).align := Left;
        {$ENDREGION}

        {$REGION ' cpt_stat_xp '}
        i := GUIform.Add;
             GUIform.Item[ i ] := TCaption.Create;
             GUIform.Item[ i ].name := 'cpt_stat_xp';
             GUIform.Item[ i ].x := 68;
             GUIform.Item[ i ].y := 43;
             GUIform.Item[ i ].w := 77;
             GUIform.Item[ i ].h := 21;
            (GUIform.Item[ i ] as TCaption).text := 'Experience';
            (GUIform.Item[ i ] as TCaption).font := 'Centaur';
            (GUIform.Item[ i ] as TCaption).size := 12;
            (GUIform.Item[ i ] as TCaption).color := Color4($c8a94a);
            (GUIform.Item[ i ] as TCaption).shadow := true;
            (GUIform.Item[ i ] as TCaption).align := Left;
        {$ENDREGION}

      {$REGION ' img_stat_vitality '}
      i := GUIform.Add;
           GUIform.Item[ i ] := TImage.Create;
           GUIform.Item[ i ].name := 'img_stat_vitality';
           GUIform.Item[ i ].x := 16;
           GUIform.Item[ i ].y := 100;
           GUIform.Item[ i ].w := 64;
           GUIform.Item[ i ].h := 64;
          (GUIform.Item[ i ] as TImage).image := txt_pack_GUI.Find('pict');
      {$ENDREGION}

        {$REGION ' cpt_stat_vitality '}
        i := GUIform.Add;
             GUIform.Item[ i ] := TCaption.Create;
             GUIform.Item[ i ].name := 'cpt_stat_vitality';
             GUIform.Item[ i ].x := 68;
             GUIform.Item[ i ].y := 0;
             GUIform.Item[ i ].w := 96;
             GUIform.Item[ i ].h := 64;
            (GUIform.Item[ i ] as TCaption).text := 'Vitality';
            (GUIform.Item[ i ] as TCaption).font := 'Centaur';
            (GUIform.Item[ i ] as TCaption).size := 12;
            (GUIform.Item[ i ] as TCaption).color := Color4($fff8e1);
            (GUIform.Item[ i ] as TCaption).shadow := true;
            (GUIform.Item[ i ] as TCaption).align := Left;
        {$ENDREGION}

          {$REGION ' cpt_stat_vitality_value '}
          i := GUIform.Add;
               GUIform.Item[ i ] := TCaption.Create;
               GUIform.Item[ i ].name := 'cpt_stat_vitality_value';
               GUIform.Item[ i ].x := 96;
               GUIform.Item[ i ].y := 0;
               GUIform.Item[ i ].w := 16;
               GUIform.Item[ i ].h := 64;
              (GUIform.Item[ i ] as TCaption).text := 'Vitality';
              (GUIform.Item[ i ] as TCaption).font := 'Centaur';
              (GUIform.Item[ i ] as TCaption).size := 12;
              (GUIform.Item[ i ] as TCaption).color := Color4($fff8e1);
              (GUIform.Item[ i ] as TCaption).shadow := true;
              (GUIform.Item[ i ] as TCaption).align := Center;
          {$ENDREGION}

            {$REGION ' btn_stat_vitality_minus '}
            i := GUIform.Add;
                 GUIform.Item[ i ] := TButton.Create;
                 GUIform.Item[ i ].name := 'btn_stat_vitality_minus';
                 GUIform.Item[ i ].x := 16;
                 GUIform.Item[ i ].y := 16;
                 GUIform.Item[ i ].w := 32;
                 GUIform.Item[ i ].h := 32;
                (GUIform.Item[ i ] as TButton).caption := '';
                (GUIform.Item[ i ] as TButton).onLeftPress := DecPlayerVP;
                (GUIform.Item[ i ] as TButton).img := txt_pack_GUI.Find('-');
                (GUIform.Item[ i ] as TButton).img_f := txt_pack_GUI.Find('-_f');
            {$ENDREGION}

            {$REGION ' btn_stat_vitality_plus '}
            i := GUIform.Add;
                 GUIform.Item[ i ] := TButton.Create;
                 GUIform.Item[ i ].name := 'btn_stat_vitality_plus';
                 GUIform.Item[ i ].x := 50;
                 GUIform.Item[ i ].y := 16;
                 GUIform.Item[ i ].w := 32;
                 GUIform.Item[ i ].h := 32;
                (GUIform.Item[ i ] as TButton).caption := '';
                (GUIform.Item[ i ] as TButton).onLeftPress := IncPlayerVP;
                (GUIform.Item[ i ] as TButton).img := txt_pack_GUI.Find('+');
                (GUIform.Item[ i ] as TButton).img_f := txt_pack_GUI.Find('+_f');
            {$ENDREGION}

      {$REGION ' img_stat_energy '}
      i := GUIform.Add;
           GUIform.Item[ i ] := TImage.Create;
           GUIform.Item[ i ].name := 'img_stat_energy';
           GUIform.Item[ i ].x := 16;
           GUIform.Item[ i ].y := 172;
           GUIform.Item[ i ].w := 64;
           GUIform.Item[ i ].h := 64;
          (GUIform.Item[ i ] as TImage).image := txt_pack_GUI.Find('pict');
      {$ENDREGION}

        {$REGION ' cpt_stat_energy '}
        i := GUIform.Add;
             GUIform.Item[ i ] := TCaption.Create;
             GUIform.Item[ i ].name := 'cpt_stat_energy';
             GUIform.Item[ i ].x := 68;
             GUIform.Item[ i ].y := 0;
             GUIform.Item[ i ].w := 96;
             GUIform.Item[ i ].h := 64;
            (GUIform.Item[ i ] as TCaption).text := 'Energy';
            (GUIform.Item[ i ] as TCaption).font := 'Centaur';
            (GUIform.Item[ i ] as TCaption).size := 12;
            (GUIform.Item[ i ] as TCaption).color := Color4($fff8e1);
            (GUIform.Item[ i ] as TCaption).shadow := true;
            (GUIform.Item[ i ] as TCaption).align := Left;
        {$ENDREGION}

          {$REGION ' cpt_stat_energy_value '}
          i := GUIform.Add;
               GUIform.Item[ i ] := TCaption.Create;
               GUIform.Item[ i ].name := 'cpt_stat_energy_value';
               GUIform.Item[ i ].x := 96;
               GUIform.Item[ i ].y := 0;
               GUIform.Item[ i ].w := 16;
               GUIform.Item[ i ].h := 64;
              (GUIform.Item[ i ] as TCaption).text := 'Energy';
              (GUIform.Item[ i ] as TCaption).font := 'Centaur';
              (GUIform.Item[ i ] as TCaption).size := 12;
              (GUIform.Item[ i ] as TCaption).color := Color4($fff8e1);
              (GUIform.Item[ i ] as TCaption).shadow := true;
              (GUIform.Item[ i ] as TCaption).align := Center;
          {$ENDREGION}

            {$REGION ' btn_stat_energy_minus '}
            i := GUIform.Add;
                 GUIform.Item[ i ] := TButton.Create;
                 GUIform.Item[ i ].name := 'btn_stat_energy_minus';
                 GUIform.Item[ i ].x := 16;
                 GUIform.Item[ i ].y := 16;
                 GUIform.Item[ i ].w := 32;
                 GUIform.Item[ i ].h := 32;
                (GUIform.Item[ i ] as TButton).caption := '';
                (GUIform.Item[ i ] as TButton).onLeftPress := DecPlayerEP;
                (GUIform.Item[ i ] as TButton).img := txt_pack_GUI.Find('-');
                (GUIform.Item[ i ] as TButton).img_f := txt_pack_GUI.Find('-_f');
            {$ENDREGION}

            {$REGION ' btn_stat_energy_plus '}
            i := GUIform.Add;
                 GUIform.Item[ i ] := TButton.Create;
                 GUIform.Item[ i ].name := 'btn_stat_energy_plus';
                 GUIform.Item[ i ].x := 50;
                 GUIform.Item[ i ].y := 16;
                 GUIform.Item[ i ].w := 32;
                 GUIform.Item[ i ].h := 32;
                (GUIform.Item[ i ] as TButton).caption := '';
                (GUIform.Item[ i ] as TButton).onLeftPress := IncPlayerEP;
                (GUIform.Item[ i ] as TButton).img := txt_pack_GUI.Find('+');
                (GUIform.Item[ i ] as TButton).img_f := txt_pack_GUI.Find('+_f');
            {$ENDREGION}

      {$REGION ' img_stat_dexterity '}
      i := GUIform.Add;
           GUIform.Item[ i ] := TImage.Create;
           GUIform.Item[ i ].name := 'img_stat_dexterity';
           GUIform.Item[ i ].x := 16;
           GUIform.Item[ i ].y := 245;
           GUIform.Item[ i ].w := 64;
           GUIform.Item[ i ].h := 64;
          (GUIform.Item[ i ] as TImage).image := txt_pack_GUI.Find('pict');
      {$ENDREGION}

        {$REGION ' cpt_stat_dexterity '}
        i := GUIform.Add;
             GUIform.Item[ i ] := TCaption.Create;
             GUIform.Item[ i ].name := 'cpt_stat_dexterity';
             GUIform.Item[ i ].x := 68;
             GUIform.Item[ i ].y := 0;
             GUIform.Item[ i ].w := 96;
             GUIform.Item[ i ].h := 64;
            (GUIform.Item[ i ] as TCaption).text := 'Dexterity';
            (GUIform.Item[ i ] as TCaption).font := 'Centaur';
            (GUIform.Item[ i ] as TCaption).size := 12;
            (GUIform.Item[ i ] as TCaption).color := Color4($fff8e1);
            (GUIform.Item[ i ] as TCaption).shadow := true;
            (GUIform.Item[ i ] as TCaption).align := Left;
        {$ENDREGION}

          {$REGION ' cpt_stat_dexterity_value '}
          i := GUIform.Add;
               GUIform.Item[ i ] := TCaption.Create;
               GUIform.Item[ i ].name := 'cpt_stat_dexterity_value';
               GUIform.Item[ i ].x := 96;
               GUIform.Item[ i ].y := 0;
               GUIform.Item[ i ].w := 16;
               GUIform.Item[ i ].h := 64;
              (GUIform.Item[ i ] as TCaption).text := 'dexterity';
              (GUIform.Item[ i ] as TCaption).font := 'Centaur';
              (GUIform.Item[ i ] as TCaption).size := 12;
              (GUIform.Item[ i ] as TCaption).color := Color4($fff8e1);
              (GUIform.Item[ i ] as TCaption).shadow := true;
              (GUIform.Item[ i ] as TCaption).align := Center;
          {$ENDREGION}

            {$REGION ' btn_stat_dexterity_minus '}
            i := GUIform.Add;
                 GUIform.Item[ i ] := TButton.Create;
                 GUIform.Item[ i ].name := 'btn_stat_dexterity_minus';
                 GUIform.Item[ i ].x := 16;
                 GUIform.Item[ i ].y := 16;
                 GUIform.Item[ i ].w := 32;
                 GUIform.Item[ i ].h := 32;
                (GUIform.Item[ i ] as TButton).caption := '';
                (GUIform.Item[ i ] as TButton).onLeftPress := DecPlayerDP;
                (GUIform.Item[ i ] as TButton).img := txt_pack_GUI.Find('-');
                (GUIform.Item[ i ] as TButton).img_f := txt_pack_GUI.Find('-_f');
            {$ENDREGION}

            {$REGION ' btn_stat_dexterity_plus '}
            i := GUIform.Add;
                 GUIform.Item[ i ] := TButton.Create;
                 GUIform.Item[ i ].name := 'btn_stat_dexterity_plus';
                 GUIform.Item[ i ].x := 50;
                 GUIform.Item[ i ].y := 16;
                 GUIform.Item[ i ].w := 32;
                 GUIform.Item[ i ].h := 32;
                (GUIform.Item[ i ] as TButton).caption := '';
                (GUIform.Item[ i ] as TButton).onLeftPress := IncPlayerDP;
                (GUIform.Item[ i ] as TButton).img := txt_pack_GUI.Find('+');
                (GUIform.Item[ i ] as TButton).img_f := txt_pack_GUI.Find('+_f');
            {$ENDREGION}

      {$REGION ' cpt_stat_sp '}
        i := GUIform.Add;
             GUIform.Item[ i ] := TCaption.Create;
             GUIform.Item[ i ].name := 'cpt_stat_sp';
             GUIform.Item[ i ].x := 0;
             GUIform.Item[ i ].y := GUIform.Find('pnl_stat').h - 26;
             GUIform.Item[ i ].w := 384;
             GUIform.Item[ i ].h := 26;
            (GUIform.Item[ i ] as TCaption).text := 'Stat Point';
            (GUIform.Item[ i ] as TCaption).font := 'Centaur';
            (GUIform.Item[ i ] as TCaption).size := 12;
            (GUIform.Item[ i ] as TCaption).color := Color4($fff8e1);
            (GUIform.Item[ i ] as TCaption).shadow := true;
            (GUIform.Item[ i ] as TCaption).align := Center;
        {$ENDREGION}

      {$REGION ' btn_stat_ok '}
      i := GUIform.Add;
           GUIform.Item[ i ] := TButton.Create;
           GUIform.Item[ i ].name := 'btn_stat_ok';
           GUIform.Item[ i ].x := GUIform.Find('pnl_stat').w - 82;
           GUIform.Item[ i ].y := GUIform.Find('pnl_stat').h - 31;
           GUIform.Item[ i ].w := 77;
           GUIform.Item[ i ].h := 26;
          (GUIform.Item[ i ] as TButton).caption := 'Save';
          (GUIform.Item[ i ] as TButton).onLeftClick := SaveStat;
          (GUIform.Item[ i ] as TButton).img := txt_pack_GUI.Find('button');
          (GUIform.Item[ i ] as TButton).img_f := txt_pack_GUI.Find('button_f');
      {$ENDREGION}

    {$REGION ' btn_stat_close '}
    i := GUIform.Add;
         GUIform.Item[ i ] := TButton.Create;
         GUIform.Item[ i ].name := 'btn_stat_close';
         GUIform.Item[ i ].x := 315;
         GUIform.Item[ i ].y := 565;
         GUIform.Item[ i ].w := 77;
         GUIform.Item[ i ].h := 26;
        (GUIform.Item[ i ] as TButton).caption := 'Close';
        (GUIform.Item[ i ] as TButton).onLeftClick := OpenStat;
        (GUIform.Item[ i ] as TButton).img := txt_pack_GUI.Find('button');
        (GUIform.Item[ i ] as TButton).img_f := txt_pack_GUI.Find('button_f');
    {$ENDREGION}


  {$REGION ' Наследование '}
  GUIform.Find('pnl_bag').SetParent( GUIform.Find('wnd_bag') );
  GUIform.Find('wnd_bag').AddChild( GUIform.Find('pnl_bag') );

      GUIform.Find('grd_bag').SetParent( GUIform.Find('pnl_bag') );
      GUIform.Find('pnl_bag').AddChild( GUIform.Find('grd_bag') );

  GUIform.Find('pnl_rune').SetParent( GUIform.Find('wnd_bag') );
  GUIform.Find('wnd_bag').AddChild( GUIform.Find('pnl_rune') );

      GUIform.Find('grd_rune').SetParent( GUIform.Find('pnl_rune') );
      GUIform.Find('pnl_rune').AddChild( GUIform.Find('grd_rune') );

  GUIform.Find('btn_bag_ok').SetParent( GUIform.Find('wnd_bag') );
  GUIform.Find('wnd_bag').AddChild( GUIform.Find('btn_bag_ok') );

  GUIform.Find('cpt_gold').SetParent( GUIform.Find('wnd_bag') );
  GUIform.Find('wnd_bag').AddChild( GUIform.Find('cpt_gold') );

  GUIform.Find('pnl_stat').SetParent( GUIform.Find('wnd_stat') );
  GUIform.Find('wnd_stat').AddChild( GUIform.Find('pnl_stat') );

      GUIform.Find('cpt_stat_name').SetParent( GUIform.Find('pnl_stat') );
      GUIform.Find('pnl_stat').AddChild( GUIform.Find('cpt_stat_name') );

      GUIform.Find('img_stat_avatar').SetParent( GUIform.Find('pnl_stat') );
      GUIform.Find('pnl_stat').AddChild( GUIform.Find('img_stat_avatar') );

          GUIform.Find('cpt_stat_health').SetParent( GUIform.Find('img_stat_avatar') );
          GUIform.Find('img_stat_avatar').AddChild( GUIform.Find('cpt_stat_health') );

          GUIform.Find('cpt_stat_mana').SetParent( GUIform.Find('img_stat_avatar') );
          GUIform.Find('img_stat_avatar').AddChild( GUIform.Find('cpt_stat_mana') );

          GUIform.Find('cpt_stat_xp').SetParent( GUIform.Find('img_stat_avatar') );
          GUIform.Find('img_stat_avatar').AddChild( GUIform.Find('cpt_stat_xp') );

      {$REGION ' Vitality '}
      GUIform.Find('img_stat_vitality').SetParent( GUIform.Find('pnl_stat') );
      GUIform.Find('pnl_stat').AddChild( GUIform.Find('img_stat_vitality') );

          GUIform.Find('cpt_stat_vitality').SetParent( GUIform.Find('img_stat_vitality') );
          GUIform.Find('img_stat_vitality').AddChild( GUIform.Find('cpt_stat_vitality') );

              GUIform.Find('cpt_stat_vitality_value').SetParent( GUIform.Find('cpt_stat_vitality') );
              GUIform.Find('cpt_stat_vitality').AddChild( GUIform.Find('cpt_stat_vitality_value') );

                  GUIform.Find('btn_stat_vitality_minus').SetParent( GUIform.Find('cpt_stat_vitality_value') );
                  GUIform.Find('cpt_stat_vitality_value').AddChild( GUIform.Find('btn_stat_vitality_minus') );

                  GUIform.Find('btn_stat_vitality_plus').SetParent( GUIform.Find('cpt_stat_vitality_value') );
                  GUIform.Find('cpt_stat_vitality_value').AddChild( GUIform.Find('btn_stat_vitality_plus') );
      {$ENDREGION}

      {$REGION ' Energy '}
      GUIform.Find('img_stat_energy').SetParent( GUIform.Find('pnl_stat') );
      GUIform.Find('pnl_stat').AddChild( GUIform.Find('img_stat_energy') );

          GUIform.Find('cpt_stat_energy').SetParent( GUIform.Find('img_stat_energy') );
          GUIform.Find('img_stat_energy').AddChild( GUIform.Find('cpt_stat_energy') );

              GUIform.Find('cpt_stat_energy_value').SetParent( GUIform.Find('cpt_stat_energy') );
              GUIform.Find('cpt_stat_energy').AddChild( GUIform.Find('cpt_stat_energy_value') );

                  GUIform.Find('btn_stat_energy_minus').SetParent( GUIform.Find('cpt_stat_energy_value') );
                  GUIform.Find('cpt_stat_energy_value').AddChild( GUIform.Find('btn_stat_energy_minus') );

                  GUIform.Find('btn_stat_energy_plus').SetParent( GUIform.Find('cpt_stat_energy_value') );
                  GUIform.Find('cpt_stat_energy_value').AddChild( GUIform.Find('btn_stat_energy_plus') );
      {$ENDREGION}

      {$REGION ' Dexterity '}
      GUIform.Find('img_stat_dexterity').SetParent( GUIform.Find('pnl_stat') );
      GUIform.Find('pnl_stat').AddChild( GUIform.Find('img_stat_dexterity') );

          GUIform.Find('cpt_stat_dexterity').SetParent( GUIform.Find('img_stat_dexterity') );
          GUIform.Find('img_stat_dexterity').AddChild( GUIform.Find('cpt_stat_dexterity') );

              GUIform.Find('cpt_stat_dexterity_value').SetParent( GUIform.Find('cpt_stat_dexterity') );
              GUIform.Find('cpt_stat_dexterity').AddChild( GUIform.Find('cpt_stat_dexterity_value') );

                  GUIform.Find('btn_stat_dexterity_minus').SetParent( GUIform.Find('cpt_stat_dexterity_value') );
                  GUIform.Find('cpt_stat_dexterity_value').AddChild( GUIform.Find('btn_stat_dexterity_minus') );

                  GUIform.Find('btn_stat_dexterity_plus').SetParent( GUIform.Find('cpt_stat_dexterity_value') );
                  GUIform.Find('cpt_stat_dexterity_value').AddChild( GUIform.Find('btn_stat_dexterity_plus') );
      {$ENDREGION}

      GUIform.Find('cpt_stat_sp').SetParent( GUIform.Find('pnl_stat') );
      GUIform.Find('pnl_stat').AddChild( GUIform.Find('cpt_stat_sp') );

      GUIform.Find('btn_stat_ok').SetParent( GUIform.Find('pnl_stat') );
      GUIform.Find('pnl_stat').AddChild( GUIform.Find('btn_stat_ok') );

  GUIform.Find('btn_stat_close').SetParent( GUIform.Find('wnd_stat') );
  GUIform.Find('wnd_stat').AddChild( GUIform.Find('btn_stat_close') );
  {$ENDREGION}


  player.bag.SetGrid( @GUIform.Find('grd_bag')^ );
  player.RunePage.SetGrid( @GUIform.Find('grd_rune')^ );
end;

procedure Render;
begin
  if RuneStack.count <> 0 then
    FntPack.Find('Tahoma').Draw2D( 10, 110, StrToPAChar(RuneStack.rune[ 0 ]), Color4 );

  if ShowMinimap then RenderMinimap( 2 );

  if ShowHUD then RenderHUD;

  GUIform.Render;

  if player <> nil then
  begin
    player.bag.Render;
    player.RunePage.Render;
  end;

  if buffer <> nil then
    buffer.texture.Draw2D( mouse.state.iX, mouse.state.iY, 64, 64 );

  // mouse
  Render2D.DrawPoint( Point2( mouse.state.iX, mouse.state.iY ), Color4($ffffff), 5 );
  FntPack.Find('Tahoma').Draw2D(
    mouse.state.iX, mouse.state.iY,
    StrToPAChar(
      FloatToStr( Round( GetMapFocusedPoint.x ))+', ' +
      FloatToStr( Round( GetMapFocusedPoint.y ))), Color4 );
end;

procedure Update;
begin
  GUIform.Find('wnd_bag').x := Window.Width - 400;
 (GUIform.Find('cpt_gold')^ as TCaption).text := 'Gold: ' + IntToStr( player.bag.gold );

 (GUIform.Find('cpt_stat_name')^ as TCaption).text := player.name + ' - Lv. ' + IntToStr( player.level );
 (GUIform.Find('cpt_stat_health')^ as TCaption).text := 'Health: ' + IntToStr(Round(player.hp)) + '/' + FloatToStr( player.hp_max );
 (GUIform.Find('cpt_stat_mana')^ as TCaption).text := 'Mana: ' + IntToStr(Round(player.mp)) + '/' + FloatToStr( player.mp_max );
 (GUIform.Find('cpt_stat_xp')^ as TCaption).text := 'Experience: ' + IntToStr(Round(player.xp)) + '/' + FloatToStr( player.xp_max );

 (GUIform.Find('cpt_stat_vitality_value')^ as TCaption).text := IntToStr( buf_vp );
 (GUIform.Find('cpt_stat_energy_value')^ as TCaption).text := IntToStr( buf_ep );
 (GUIform.Find('cpt_stat_dexterity_value')^ as TCaption).text := IntToStr( buf_dp );

 (GUIform.Find('cpt_stat_sp')^ as TCaption).text := 'Stat point: ' + IntToStr( buf_sp );

  GUIform.Update;
end;

procedure Free;
begin

end;


procedure OpenBag;
begin
  GUIform.Find('wnd_bag').SetVisible( not GUIform.Find('wnd_bag').visible );
  GUIform.Find('wnd_bag').SetEnabled( not GUIform.Find('wnd_bag').enabled );
end;

procedure OpenStat;
begin
  GUIform.Find('wnd_stat').SetVisible( not GUIform.Find('wnd_stat').visible );
  GUIform.Find('wnd_stat').SetEnabled( not GUIform.Find('wnd_stat').enabled );

  buf_ep := player.energy;
  buf_vp := player.vitality;
  buf_dp := player.dexterity;
  buf_sp := player.sp;
end;

procedure SaveStat;
begin
  player.energy := buf_ep;
  player.vitality := buf_vp;
  player.dexterity := buf_dp;
  player.sp := buf_sp;

  OpenStat;
end;

procedure OpenMinimap;
begin
  ShowMinimap := not ShowMinimap;
end;

procedure OpenHUD;
begin
  ShowHUD := not ShowHUD;
end;


procedure SwitchDebug;
begin
  debug := not debug;
end;


procedure IncPlayerEP;
begin
  if buf_sp > 0 then
  begin
    Inc( buf_ep );
    Dec( buf_sp );
  end;
end;

procedure DecPlayerEP;
begin
  if buf_ep - player.energy > 0 then
  begin
    Inc( buf_sp );
    Dec( buf_ep );
  end;
end;


procedure IncPlayerVP;
begin
  if buf_sp > 0 then
  begin
    Inc( buf_vp );
    Dec( buf_sp );
  end;
end;

procedure DecPlayerVP;
begin
  if buf_vp - player.vitality > 0 then
  begin
    Inc( buf_sp );
    Dec( buf_vp );
  end;
end;


procedure IncPlayerDP;
begin
  if buf_sp > 0 then
  begin
    Inc( buf_dp );
    Dec( buf_sp );
  end;
end;

procedure DecPlayerDP;
begin
  if buf_dp - player.dexterity > 0 then
  begin
    Inc( buf_sp );
    Dec( buf_dp );
  end;
end;


procedure RenderMinimap( scale : Byte );
var
  x : Integer;
  y : Integer;
  i : Integer;
  j : Integer;
  k : Integer;
  posx : Integer;
  posy : Integer;
begin
         {
  posx := 0;
  posy := 0;

  for j := 0 to MAP_HEIGHT - 1 do
  for i := 0 to MAP_WIDTH - 1 do
    for y := 0 to 15 do
    for x := 0 to 15 do
    begin
      case Game.map.region[ i + 1, j + 1 ].tile[ 1 ][ x + 1, y + 1 ] of
        0:;
        1: Render2D.DrawPoint( Point2(
                                       posx + ( i * 16 * scale ) + x * scale,
                                       posy + ( j * 16 * scale ) + y * scale
                                      ),
                               Color4($916D4F), scale
                              );
        2: Render2D.DrawPoint( Point2(
                                       posx + ( i * 16 * scale ) + x * scale,
                                       posy + ( j * 16 * scale ) + y * scale
                                      ),
                               Color4($7C8C43), scale
                              );
      end;

      case Game.map.region[ i + 1, j + 1 ].tile[ 0 ][ x + 1, y + 1 ] of
        0:;
        1: Render2D.DrawPoint( Point2(
                                       posx + ( i * 16 * scale ) + x * scale,
                                       posy + ( j * 16 * scale ) + y * scale
                                      ),
                               Color4, scale
                              );
      end;
    end;

      Render2D.DrawPoint( Point2(
                                  posx + player.pos.x / 32 * scale,
                                  posy + player.pos.y / 32 * scale
                                 ),
                          Color4($4040FF), scale
                         );

      for k := 0 to Length( mobStack.mob ) - 1 do
        if not mobStack.mob[ k ].isDead then
          Render2D.DrawPoint( Point2(
                                    posx + mobStack.mob[ k ].pos.x / 32 * scale,
                                    posy + mobStack.mob[ k ].pos.y / 32 * scale
                                     ),
                              Color4($9D1414), scale
                             );         }
end;

procedure RenderHUD;
var
  i: Integer;
  j: Integer;
  k: Byte;
  x : Integer;
  y : Integer;
  w : Integer;
  h : Integer;
begin
  txt_pack_GUI.Find('potion_r').Draw2D( Round(Window.Width / 2 - 48), Window.Height - 50, 48, 48 );
  txt_pack_GUI.Find('potion_b').Draw2D( Round(Window.Width / 2), Window.Height - 50, 48, 48 );
  txt_pack_GUI.Find('corner').Draw2D( Round(Window.Width / 2 - 37.5), Window.Height - 62, 75, 20 );
  txt_pack_GUI.Find('hud').Draw2D( Round(Window.Width / 2 - 176), Window.Height - 42, 128, 32 );
  txt_pack_GUI.Find('hud').Draw2D( Round(Window.Width / 2 + 48), Window.Height - 42, 128, 32 );

  Render2d.DrawSpriteC(
                        txt_pack_GUI.Find('hud_hp')^,
                        Point2( Round(Window.Width / 2 - 48 ), Window.Height - 42 ),
                        Point2( -128 * player.GetHP, 32 ),
                        rectf( 0, 0, 128 * player.GetHP, 32 )
                       );

  Render2d.DrawSpriteC(
                        txt_pack_GUI.Find('hud_mp')^,
                        Point2( Round(Window.Width / 2 + 48 ), Window.Height - 42 ),
                        Point2( 128 * player.GetMP, 32 ),
                        rectf( 0, 0, 128 * player.GetMP, 32 )
                       );

  // rune

  for i := 0 to 2 do
  for j := 0 to 2 do
  begin
    txt_pack_GUI.Find('potion').Draw2D( i*48, j*48, 48, 48 );
  end;

  Render2d.LineWidth( 5 );
    i := Round( RuneStack.time / 20 * 144 );
    Render2D.DrawLine( Point2( 0, 144 ), Point2( i, 144 ), Color4($9d1414) );
  Render2d.LineWidth( 1 );

  for i := 0 to KeyStack.count - 1 do
  begin
    case KeyStack.key[ i ] of
      71: txt_pack_GUI.Find('potion_y').Draw2D( 0 , 0, 48, 48 ); // num 7
      72: txt_pack_GUI.Find('potion_y').Draw2D( 48, 0, 48, 48 ); // num 8
      73: txt_pack_GUI.Find('potion_y').Draw2D( 96, 0, 48, 48 ); // num 9
      74: ;
      75: txt_pack_GUI.Find('potion_y').Draw2D( 0 , 48, 48, 48 ); // num 4
      76: txt_pack_GUI.Find('potion_y').Draw2D( 48, 48, 48, 48 ); // num 5
      77: txt_pack_GUI.Find('potion_y').Draw2D( 96, 48, 48, 48 ); // num 6
      78: ;
      79: txt_pack_GUI.Find('potion_y').Draw2D( 0 , 96, 48, 48 ); // num 1
      80: txt_pack_GUI.Find('potion_y').Draw2D( 48, 96, 48, 48 ); // num 2
      81: txt_pack_GUI.Find('potion_y').Draw2D( 96, 96, 48, 48 ); // num 3
      82: ;
    end;
  end;

  for j := 0 to 2 do
  for i := 0 to 2 do
  begin
    k := j * 3 + i;

    x := i * 48;
    y := j * 48;
    w := 48;
    h := 48;

    if player.RunePage.item[ k ] <> nil then
    begin
      if player.RunePage.item[ k ].texture <> nil then
        player.RunePage.item[ k ].texture.Draw2D( x, y, w, h );
    end;
  end;
end;

end.

defmodule Window do
  defstruct [:frame, :t_len]

  use Bitwise

  @wxHORIZONTAL 4
  @wxVERTICAL 8

  @wxLEFT 16
  @wxRIGHT 32
  @wxUP 64
  @wxDOWN 128
  @wxALL @wxLEFT ||| @wxRIGHT ||| @wxUP ||| @wxDOWN

  @wxALIGN_CENTER 256 ||| 2048
  @wxEXPAND 8192
  @wxSHAPED 16384
  @wxFONTWEIGHT_BOLD 92

  def new() do
    :wx.new()

    f = :wxFrame.new(:wx.null(), -1, 'Snake Game')

    t1 = :wxStaticText.new(f, -1, 'Snake Len:')
    fnt = :wxStaticText.getFont(t1)
    :wxFont.setWeight(fnt, @wxFONTWEIGHT_BOLD)
    :wxStaticText.setFont(t1, fnt)

    t2 = :wxStaticText.new(f, -1, '--')

    t3 = :wxStaticText.new(f, -1, 'bottom line')

    c = :wxPanel.new(f, [size: {300, 300}])
    :wxPanel.setBackgroundColour(c, {0, 255, 0})

    s = :wxBoxSizer.new(@wxVERTICAL)
    s_stat = :wxBoxSizer.new(@wxHORIZONTAL)
    :wxBoxSizer.add(s_stat, t1)
    :wxBoxSizer.addSpacer(s_stat, 3)
    :wxBoxSizer.add(s_stat, t2)
    :wxBoxSizer.add(s, s_stat, [proportion: 0, flag: @wxALIGN_CENTER ||| @wxALL, border: 5])
    :wxBoxSizer.add(s, c, [proportion: 1, flag: @wxSHAPED ||| @wxALIGN_CENTER])
    :wxBoxSizer.add(s, t3, [proportion: 0, flag: @wxALIGN_CENTER])
    :wxFrame.setSizer(f, s)

    %Window{frame: f, t_len: t2}
  end

  def show(win) do
    if :wxWindow.isShown(win.frame) do
      {:error, :already_shown}
    else
      true = :wxFrame.show(win.frame)
    end
  end
end

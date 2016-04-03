defmodule SnakeGame.Window do
  alias SnakeGame.Window

  defmodule Objects do
    defstruct [:frame, :t_len, :canvas, :snake_pen, :rabbit_pen, :border_pen, :field_brush]
  end
  defmodule Field do
    defstruct [:snake_points, :rabbits]
  end
  defstruct objects: nil, field: nil, controller: nil

  @behaiour :wx_object

  use Bitwise

  require Record
  Record.defrecord :wx, [:id, :obj, :userData, :event]
  Record.defrecord :wxClose, [:type]
  Record.defrecord :wxPaint, [:type]
  Record.defrecord :wxSize, [:type, :size, :rect]
  Record.defrecord :wxKey, [:type, :x, :y, :keyCode, :controlDown,
    :shiftDown, :altDown, :metaDown, :scanCode, :uniChar, :rawCode, :rawFlags]

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

  @wxSOLID 100

  @wxkLEFT 314
  @wxkUP 315
  @wxkRIGHT 316
  @wxkDOWN 317
  @wxkSPACE 32

  def start_link(controller) do
    :wx_object.start_link(__MODULE__, {controller}, [])
  end

  def show(object) do
    :wx_object.call(object, :show)
  end

  def draw(object, snake_points, rabbits) do
    :wx_object.call(object, {:draw, snake_points, rabbits})
  end

  def init({controller}) do
    :wx.new()

    f = :wxFrame.new(:wx.null(), -1, 'Snake Game')

    t1 = :wxStaticText.new(f, -1, 'Snake Len:')
    fnt = :wxStaticText.getFont(t1)
    :wxFont.setWeight(fnt, @wxFONTWEIGHT_BOLD)
    :wxStaticText.setFont(t1, fnt)

    t2 = :wxStaticText.new(f, -1, '--')

    t3 = :wxStaticText.new(f, -1, 'bottom line')

    c = :wxPanel.new(f, [size: {200, 200}])
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

    sp = :wxPen.new({255, 255, 0}, [width: 3, style: @wxSOLID])
    rp = :wxPen.new({255, 255, 255}, [width: 3, style: @wxSOLID])
    brush = :wxBrush.new({0, 255, 0})
    bp = :wxPen.new({0, 0, 255}, [width: 1, style: @wxSOLID])

    :wxFrame.connect(f, :close_window)
    :wxPanel.connect(c, :paint, [:callback])
    :wxPanel.connect(c, :size)
    :wxFrame.connect(f, :key_up)

    {f, %Window{
      objects: %Objects{
        frame: f,
        t_len: t2,
        canvas: c,
        snake_pen: sp,
        rabbit_pen: rp,
        field_brush: brush,
        border_pen: bp},
      field: %Field{},
      controller: controller}}
  end

  def handle_call(:show, _from, win) do
    unless :wxWindow.isShown(win.objects.frame) do
      true = :wxFrame.show(win.objects.frame)
    end
    {:reply, :ok, win}
  end

  def handle_call({:draw, snake_points, rabbits}, _from,  win) do
    :wxWindow.refresh win.objects.canvas
    {:reply, :ok, put_in(win.field, %Field{snake_points: snake_points, rabbits: rabbits})}
  end

  def handle_event(wx(event: wxClose()), win) do
    {:stop, :normal, win}
  end

  def handle_event(wx(event: wxKey(type: :key_up, keyCode: code)), win) do
    case code do
      @wxkLEFT  -> dir_cmd(win.controller, :left)
      @wxkUP    -> dir_cmd(win.controller, :up)
      @wxkRIGHT -> dir_cmd(win.controller, :right)
      @wxkDOWN  -> dir_cmd(win.controller, :down)
      @wxkSPACE -> GenEvent.sync_notify win.controller, :pause_cmd
      _ -> :ignore
    end
    {:noreply, win}
  end

  def handle_event(wx(event: wxSize(size: {w, _h})), win) do
    snake_width = calc_width(w)
    :wxPen.setWidth(win.objects.snake_pen, snake_width)
    :wxPen.setWidth(win.objects.rabbit_pen, snake_width)
    :wxPen.setWidth(win.objects.border_pen, w - snake_width * grid_size())
    :wxWindow.refresh win.objects.canvas
    {:noreply, win}
  end

  def handle_sync_event(wx(event: wxPaint()), _wxObj, win) do
    dc = :wxPaintDC.new(win.objects.canvas)
    {w, h} = :wxDC.getSize(dc)
    bmp = :wxBitmap.new(w, h)
    mdc = :wxMemoryDC.new(bmp)

    snake_width = calc_width(w)
    offset = div(w - snake_width * grid_size(), 2) + div(snake_width, 2)
    factor = snake_width
    f_transform = fn
      {i_num, i_denum} -> div(i_num * factor, i_denum) + offset
      i -> i * factor + offset
    end

    dc_pp = if win.field.snake_points == nil do
      nil
    else
      Enum.map(win.field.snake_points, &(transform_point &1, f_transform))
    end

    do_draw_snake(win, dc_pp, mdc)
    win.field.rabbits |> Enum.map(&(transform_point &1, f_transform)) |> Enum.each(&(do_draw_rabbit(win, &1, mdc)))
    :wxDC.blit(dc, {0, 0}, {w, h}, mdc, {0, 0})

    :wxMemoryDC.destroy(mdc)
    :wxBitmap.destroy(bmp)
    :wxPaintDC.destroy(dc)
  end

  def handle_info(_msg, win), do: {:noreply, win}

  def terminate(_reason, win) do
    :wxFrame.destroy(win.objects.frame)
    :wxPen.destroy(win.objects.snake_pen)
    :wxBrush.destroy(win.objects.field_brush)
    GenEvent.sync_notify win.controller, :quit_cmd
  end

  def code_change(_, _, win), do: {:ok, win}

  defp do_draw_snake(win, pp, dc) do
    :wxDC.setBackground(dc, win.objects.field_brush)
    :wxDC.clear(dc)

    :wxDC.setPen(dc, win.objects.border_pen)
    :wxDC.setBrush(dc, :wxe_util.get_const(:wxTRANSPARENT_BRUSH))
    border_width = :wxPen.getWidth(win.objects.border_pen)
    size = :wxPen.getWidth(win.objects.snake_pen) * grid_size()
    size = size + border_width + 1
    shift = rem(border_width, 2)
    :wxDC.drawRectangle(dc, {0 - shift, 0 - shift}, {size, size})

    if pp != nil do
      :wxDC.setPen(dc, win.objects.snake_pen)
      :wxDC.drawLines(dc, pp)
    end
  end

  defp do_draw_rabbit(win, point, dc) do
    :wxDC.setPen(dc, win.objects.rabbit_pen)
    :wxDC.drawLine(dc, point, point)
  end

  defp calc_width(w) do
    if rem(w, grid_size()) == 0 do
      div(w, grid_size()) - 1
    else
      div(w, grid_size())
    end
  end

  defp transform_point({x, y}, f_transform) do
    {f_transform.(x), f_transform.(y)}
  end

  defp grid_size(), do: 30

  defp dir_cmd(controller, dir) do
    GenEvent.sync_notify controller, {:dir_cmd, dir}
  end

end

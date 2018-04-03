

class Controller
  @@keybindings = {
    "\cq"   => :quit,
    "\cs"   => :save,
    "\e[1;5A" => [:up,10],
    "\e[1;5B" => [:down, 10],
    "\e[A"  => :up,
    "\e[B"  => :down,
    "\e[C"  => :right,
    "\e[D"  => :left,
    "\ck"   => :kill,
    "\cy"   => :yank,
    "\e[6~" => :page_down,
    "\e[5~" => :page_up,
    "\cp"   => :up,
    "\cn"   => :down,
    "\cu"   => :delete_before,
    "\c_"   => :history_undo,
#    "\cr"	=> :history_redo,
    "\f"    => :refresh,
    "\r"    => :enter,
    "\t"    => :indent,
    "\e2"   => :split_vertical,
    "\e3"   => :split_horizontal,
    "\cf"   => :find,
    "\cg"   => :goto_line,
    "\co"   => :open,
    "\ca"   => :line_home,
    "\e[7~" => :line_home,
    "\ce"   => :line_end,
    "\e[8~" => :line_end,
    "\ch"   => :backspace,
    "\177"  => :backspace,
    "\cd"   => :delete,
    "\e[P"  => :delete,
    "\cR"   => :reload
  }

  def initialize(target)
    @target = target
  end

  def read_char
    IO.console.raw do
      return if !IO.select([$stdin],nil,nil, 0.01)

      char = $stdin.getc

      return char if char != "\e"

      maxlen = 6
      @cnt ||= 0
      begin
        char << $stdin.read_nonblock(maxlen)
        @message = char.to_s + " / #{@cnt}"
        @cnt += 1
      rescue IO::WaitReadable
        return char if maxlen == 2
        maxlen -= 1
        retry
      end

      char
    end
  end

  def handle_input
    char = read_char
    command(char) if char
    return char  
  end

  def command(char)
    c = @@keybindings[char]
    if !c && char =~ /\A[[:print:]]+\Z/
      c = [:insert_char, char]
    end

    if c
      @lastcmd = c
      @target.instance_eval do
        send(*Array(c))
      end
    end
  end
end

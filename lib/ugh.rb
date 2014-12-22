class StandardError
  def initialize short_message = 'unspecified ugh', **attributes
    super short_message
    @short_message = short_message
    @attributes = attributes
    return
  end

  attr_accessor :short_message
  attr_accessor :attributes

  def to_s attributes_in_parentheses: true
    s = '' << @short_message
    firstp = true
    @attributes.each_pair do |name, value|
      if firstp then
        s << (attributes_in_parentheses ? ' (' : ', ')
        firstp = false
      else
        s << ', '
      end
      firstp = false
      s << name.to_s << ': ' << value.inspect
    end
    s << ')' if attributes_in_parentheses and !firstp
    return s
  end

  def inspect
    return '#<' + to_s(attributes_in_parentheses: false) + '>'
  end

  def [] name
    return @attributes[name.to_sym]
  end

  def []= name, value
    return @attributes[name.to_sym] = value
  end
end

def ugh short_message = 'unspecified ugh', **attr
  if short_message.is_a? Class then
    # Uh-oh, it's not a short message at all but an exception
    # class (or so we should hope).  Let's instantiate it.
    raise short_message.new(**attr)
  else
    raise Ugh.new(short_message, **attr)
  end
end

class Ugh < RuntimeError
end

def ugh? klass = Ugh, **attributes
  begin
    return yield
  rescue klass => exception
    evaluated_attributes = {}
    attributes.each_pair do |name, value|
      if value.is_a? Proc then
        unless exception.attributes.has_key? name then
          value = value.call
        else
          value = nil
        end
      end
      evaluated_attributes[name] = value
    end
    exception.attributes =
        evaluated_attributes.merge exception.attributes
    raise exception
  end
end

class SystemCallError
  def strerror
    # Remove in-sentence bits of context such as filename(s)
    # by looking up the error message without context:
    m = SystemCallError.new(errno).message

    # Fix message case by downcasing the initial uppercase
    # letter except if it's immediately followed by another
    # uppercase letter, as in [["RPC version wrong"]]:
    m = m.sub(/\A[[:upper:]](?![[:upper:]])/){$&.downcase}

    return m
  end
end

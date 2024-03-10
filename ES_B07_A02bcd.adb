With Ada.Text_IO; use Ada.Text_IO;
with ada.numerics.discrete_random;

-- 2b, c, d
procedure puffer is

-- random
type randRange is new Integer range 1..100;
   package Rand_Int is new ada.numerics.discrete_random(randRange);
   use Rand_Int;
   gen : Generator;
   num : randRange;
   
--FIFO
 task type FIFO is
  entry read (c: in Integer);
  entry write (c: out Integer);
 end FIFO;
 task body FIFO is
  N : Integer := 5;
  counter_read : Integer := 1;
  counter_write : Integer := 1;
  int_array : array (1..N) of Integer;
  full : Integer := 0;
 begin
  Ada.Text_IO.Put_Line("fifo started");
  loop
   select when ((counter_write - counter_read <= N and counter_read <= counter_write) or (counter_read - counter_write < N and counter_write < counter_read)) and full = 0 =>
    accept read(c: in Integer) do
     Ada.Text_IO.Put_Line("fifo read " & Integer'Image(c));
     int_array(counter_write) := c;
     if counter_write < N then
      counter_write := counter_write + 1;
     else 
      counter_write := 1;
     end if; 
     if counter_write=counter_read then
      full := 1;
     end if; 
    end read;
    
   or when (not (counter_read - counter_write = 0)) or full = 1 =>
    accept write(c: out Integer) do
     c := int_array(counter_read);
     Ada.Text_IO.Put_Line("fifo wrote " & Integer'Image(c));
     if counter_read < N then
      counter_read := counter_read + 1;
     else 
      counter_read := 1;
     end if; 
     if full = 1 then
      full := 0;
     end if; 
    end write;
    
   or when not (((counter_write - counter_read <= N and counter_read <= counter_write) or (counter_read - counter_write < N and counter_write < counter_read)) and full = 0) =>
    accept read(c: in Integer) do
    Ada.Text_IO.Put_Line("fifo cant read, lost message " & Integer'Image(c));
    end read;
    
   or when counter_read - counter_write = 0 and full = 0 =>
    accept write(c: out Integer) do
    Ada.Text_IO.Put_Line("fifo write request and array empty, wrote 0");
    c := 0;
   end write;
   end select;
  end loop;
 end FIFO;
 FF : FIFO;
 
 --producer
 task type producer is
  entry write;
 end producer; 
 task body producer is 
 begin
  Ada.Text_IO.Put_Line("producer started");
  loop
   accept write do
    reset(gen);
    num := random(gen);
    Ada.Text_IO.Put_Line("producer messaged " & randRange'Image(num));
    FF.read(Integer'Value(randRange'Image(num)));
   end write;
  end loop;
 end producer;
 
 --consumer
 task type consumer is
  entry read;
 end consumer; 
 task body consumer is
  val : Integer;
 begin
  Ada.Text_IO.Put_Line("consumer started");
  loop
   accept read do
    FF.write(val);
    Ada.Text_IO.Put_Line("consumer received " & Integer'Image(val));
   end read;
  end loop;
 end consumer; 
 
 pro : array (1..3) of producer;
 con : array (1..3) of consumer;
 
begin
 for I in 1 .. 15 loop
  reset(gen);
  num := random(gen);
  if Integer'Value(randRange'Image(num)) mod 5 = 0 then
   con(1).read;
  elsif Integer'Value(randRange'Image(num)) mod 17 = 0 then
   con(2).read;
  elsif Integer'Value(randRange'Image(num)) mod 13 = 0 then
   con(3).read;
  elsif Integer'Value(randRange'Image(num)) mod 11 = 0 then
   pro(1).write;
  elsif Integer'Value(randRange'Image(num)) mod 7 = 0 then
   pro(2).write;
  else
   pro(3).write;
  end if;
 end loop;
end puffer;
-- 2a

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
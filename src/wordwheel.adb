with Ada.Command_Line; use Ada.Command_Line;
with Ada.Text_IO; use Ada.Text_IO;
with Ada.Characters.Handling; use Ada.Characters.Handling;
with Ada.Text_IO.Unbounded_IO; use Ada.Text_IO.Unbounded_IO;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with Ada.Containers.Ordered_Sets;

procedure WordWheel is

-- Author    : David Haley;
-- Created   : 18/02/2025
-- Last Edit : 21/02/2025
-- 21/02/2025: Put_CPU_time removed, not supported on RPI 2.

-- This solves the Courier Mail WordWheel pusel using the Linux Dictionary

Words_Name : String := "/usr/share/dict/words";
Word_Length : constant Positive := 8;
subtype Wheel_Words is String (1 .. Word_Length);

package Word_Stores is new Ada.Containers.Ordered_Sets (Wheel_Words);
use Word_Stores;

   procedure Build_Word_Store (Word_Store : out Word_Stores.Set) is
   
   Word_File : File_Type;
   Text : Unbounded_String;
   
   begin -- Build_Word_Store
      Clear (Word_Store);
      Open (Word_File, In_file, Words_Name);
      while not End_of_File (Word_File) loop
         Get_Line (Word_File, Text);
         if Length (Text) = Word_Length and then Index (Text, "'") = 0 then
            Include (Word_Store, To_String (Text));
         end if; -- Length (Text) = Word_Length and then Index (Text, "'") = 0
      end loop; -- not End_of_File (Word_File)
      Close (Word_File);
   end Build_Word_Store;
   
   function Backwards (Wheel_Word : Wheel_Words) return Wheel_Words is
   
      Result : Wheel_Words;
      
   begin -- Backwards
      for I in Positive range 1 .. Word_Length - 1 loop
         Result (I) := Wheel_Word (Word_Length - I);
      end loop; -- I in Positive range 1 .. Word_Length - 1
      Result (Word_Length) := Wheel_Word (Word_Length);
      return Result;
   end Backwards;
   
   procedure Solve (Word_Store : in Word_Stores.Set;
                    Wheel_Word : in Wheel_Words) is
      
      Offset : Integer;
      Test_Word : Wheel_Words;
      
   begin -- Solve
      for X in Positive range 1 .. Word_Length loop
         Offset := Word_Length - X;
         for I in Positive range 1 .. Word_Length loop
            if I + Offset > Word_Length then
               Test_Word (I) := 
                 To_Lower (Wheel_Word (I + Offset - Word_Length));
            else
               Test_Word (I) := To_Lower (Wheel_Word (I + Offset));
            end if; -- I + Offset > Word_Length
         end loop; -- I in Positive range 1 .. Word_Length
         for Ch in Character range 'a' .. 'z' loop
            Test_Word (X) := Ch;
            if Contains (Word_Store, Test_Word) then
               Put_Line (Test_Word);
            end if; -- Contains (Word_Store, Test_Word)
         end loop; -- Ch in Character range 'a' .. 'z'
      end loop; -- X in Positive range 1 .. Word_Length
   end Solve;

   Word_Store : Word_Stores.Set;
   Wheel_Word : Wheel_Words;

begin -- Word_Wheel
   Put_Line ("WordWheel version 20250219");
   if Argument_Count /= 1 or else Argument (1)'Length /= Word_Length then
      Put_Line ("Usage wordwheel Wheel_Word");
      Put_Line ("Where Wheel_Word is seven letters followed by '?'");
      Put_Line ("Example: wordwheel EREHHTI?");
   else
      Build_Word_Store (Word_Store);
      Wheel_Word := Argument (1);
      if Wheel_Word (Word_Length) /= '?' then
         Put_Line ("Must end in '?', found '" & Wheel_Word (Word_Length) & "'");
      else
         Solve (Word_Store, Wheel_Word);
         Solve (Word_Store, Backwards (Wheel_Word));
      end if; -- Wheel_Word (Word_Length) /= '?'
   end if; -- Argument_Count /= 1 or else Argument (1)'Length /= Word_Length
end WordWheel;

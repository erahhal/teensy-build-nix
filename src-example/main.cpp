#include "WProgram.h"

extern "C" int main(void)
{
  Serial.begin(9600);

  Serial.println("look ma, no Arduino IDE!");

  for (;;) {}
}

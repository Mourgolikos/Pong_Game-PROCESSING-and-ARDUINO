void loop()
{
    //send 'Hello, world!' over the serial port
    Serial.println("Hello, world!");
    //wait 100 milliseconds to avoid flooding the serial port
    delay(100);
}

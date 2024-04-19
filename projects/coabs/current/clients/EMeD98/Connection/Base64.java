/*  
 * Base64.java; imported from .. 7/14/98
 */
package Connection;

import java.io.*;

public class Base64{
  public static byte[] btable=new byte[64];
  public static char[] ctable={
    'A','B','C','D','E','F','G','H','I','J','K','L','M',
    'N','O','P','Q','R','S','T','U','V','W','X','Y','Z',
    'a','b','c','d','e','f','g','h','i','j','k','l','m',
    'n','o','p','q','r','s','t','u','v','w','x','y','z',
    '0','1','2','3','4','5','6','7','8','9','/','+'
  };
  static{
    for (int i=0;i<64;i++){
      btable[i]=(byte)ctable[i]; 
    }
  }

  static String encodingISO="ISO-8859-1";

  public static String Base64EncodeString(String d)
    throws UnsupportedEncodingException{
    InputStream i=new ByteArrayInputStream(d.getBytes(encodingISO));
    ByteArrayOutputStream o=new ByteArrayOutputStream();
    Base64Encode(i,o);
    return o.toString(encodingISO);
  }

  public static String Base64DecodeString(String d)
    throws UnsupportedEncodingException{
    InputStream i=new ByteArrayInputStream(d.getBytes(encodingISO));
    ByteArrayOutputStream o=new ByteArrayOutputStream();
    Base64Decode(i,o);
    return o.toString(encodingISO);
  }

  public static void Base64Encode(InputStream i, OutputStream o){
    byte[] dChunk=new byte[3];
    byte[] eChunk=new byte[4];
    boolean eof1=false;
    boolean eof=false;
    int ch;
    while(!eof){
      try{
        if(-1==(ch=i.read())){ch=0;eof=true;continue;}
        dChunk[0]=(byte)ch;
        eChunk[0]=btable[(dChunk[0]/4)&0x3f];
        if(-1==(ch=i.read())){ch=0;eof=eof1=true;}
        dChunk[1]=(byte)ch;
        eChunk[1]=btable[((dChunk[1]/16)&0x0f)+((dChunk[0]*16)&0x30)];
        if(-1==(ch=i.read())){ch=0;eof=true;}
        dChunk[2]=(byte)ch;
        eChunk[2]=btable[((dChunk[2]/64)&0x03)+((dChunk[1]*4)&0x3c)];
        eChunk[3]=btable[dChunk[2]&0x3f];
        if (eof1){eChunk[2]=(byte)'=';}
        if (eof) {eChunk[3]=(byte)'=';}
        o.write(eChunk[0]);
        o.write(eChunk[1]);
        o.write(eChunk[2]);
        o.write(eChunk[3]);
        o.flush();
      } catch(IOException x){
System.err.println("Exception");
        eof=true;
      }
    }
  }

  public static void Base64Decode(InputStream i, OutputStream o){
    byte[] dChunk=new byte[3];
    byte[] eChunk=new byte[4];
    boolean eof=false;
    int count;
    int ch;
    while(!eof){
      try{
        if(-1==(ch=i.read())){break;}
//0
        eChunk[0]=lookup(ch);
        if(-1==(ch=i.read())){ch='=';eof=true;}
//1
        eChunk[1]=lookup(ch);
        dChunk[0]  = (byte)((eChunk[0]*4)&0xfc);
        dChunk[0] += (eChunk[1]/16)&0x03;
o.write(dChunk[0]);
        if(-1==(ch=i.read())){ch='=';eof=true;}
//2
        if (ch!=(int)'='){
          eChunk[2]=lookup(ch);
          dChunk[1]  = (byte)((eChunk[1]*16)&0xf0);
          dChunk[1] += (eChunk[2]/4)&0x0f;
          o.write(dChunk[1]);
        }

          if(-1==(ch=i.read())){ch='=';eof=true;}
//3
          if(ch!=(int)'='){
            eChunk[3]=lookup(ch);
            dChunk[2]  = (byte)((eChunk[2]*64)&0xc0);
            dChunk[2] += (eChunk[3])&0x3f;
            o.write(dChunk[2]);
          }
      } catch(IOException x){
        eof=true;
      }
    }
  }

  public static byte lookup(int b){
    for (byte i=0;i<btable.length;i++){
      if (b==btable[i]){return i;}
    }
    return -1;
  }

  public static void main(String[] args){
    try{
      System.out.println(Base64.Base64EncodeString(args[0]));
      System.out.println(Base64.Base64DecodeString(args[1]));
    } catch(UnsupportedEncodingException x){
    }
  }
}

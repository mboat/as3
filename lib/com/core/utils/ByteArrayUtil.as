package com.core.utils
{
	import com.core.data.struct.Long;
	
	import flash.utils.ByteArray;
	
	/**
	 * @descr
	 * @date 2016-9-19
	 * @author nos
	 */
	public class ByteArrayUtil
	{
		private static var compress:Boolean=false;
		
		public static function readInt(buffer:ByteArray):int
		{
			if(compress){
				return decodeZigzag32(readRawVarInt32(buffer));
			}else{
				return buffer.readInt();
			}
		}
		
		public static function writeInt(buffer:ByteArray,value:int):void{
			if(compress){
				writeRawVarInt32(buffer,value);
			}else{
				buffer.writeInt(value);
			}
		}
		
		public static function readLong(buffer:ByteArray):Long{
			if(compress){
				return decodeZigzag64(readRawVarInt64(buffer));
			}else{
				return Long.readLong(buffer);
			}
		}
		
		public static function writeLong(buffer:ByteArray,value:Long):void{
			if(compress){
				return writeRawVarInt64(buffer,encodeZigzag64(value));
			}else{
				return Long.writeLong(buffer,value);
			}
		}
		
		public static function writeRawVarInt64(buffer:ByteArray,value:Long):void{
			while(true){
				var byte:int=value.byteValue();
				if(value.and(Long.MARK).equal(Long.ZERO)){
					writeRawByte(buffer,byte);
					return;
				}else{
					writeRawByte(buffer,(byte&&0x7f)|0x80);
					value=value.shiftRightUn(7);
				}
			}
		}
		
		public static function readRawVarInt64(buffer:ByteArray):Long{
			var shift:int=0;
			var result:Long =new Long();
			while(shift<64){
				var byte:int=buffer.readByte();
				var tempLong:Long =new Long(byte&0x7f,0);
				tempLong=tempLong.shiftLeft(shift);
				result=result.or(tempLong);
				if((byte&0x80)==0){
					return result;
				}
				shift+=7;
			}
			return result;
		}
		
		
		public static function writeRawVarInt32(buffer:ByteArray,value:int):void{
			while(true){
				if((value & ~0x7f)==0){
					writeRawByte(buffer,value);
					return;
				}else{
					writeRawByte(buffer,(value&0x7f)|0x80);
					value>>>=7;
				}
			}
		}
		
		public static function readRawVarInt32(buffer:ByteArray):int{
			var i:int=0;
			var len:int=buffer.bytesAvailable>4?4:buffer.bytesAvailable;
			var result:int=0;
			var tmp:int;
			while(true){
				tmp=buffer.readByte();
				result |=(tmp&0x7f)<<7*i;
				if(tmp>=0){
					break;
				}
				if(i>len){
					break;
				}
			}
			return result;
//			var tmp:int=buffer.readByte();
//			if(tmp>=0){
//				return tmp;
//			}
//			var result:int=tmp&0x7f;
//			if((tmp=buffer.readByte())>=0){
//				result |=tmp<<7;
//			}else {
//				result |=(tmp&0x7f)<<7;
//				if((tmp=buffer.readByte())>=0){
//					result |=tmp<<14;
//				}else{
//					result |=(tmp&0x7f)<<14;
//					if((tmp=buffer.readByte())>=0){
//						result |=tmp<<21;
//					}else{
//						result |=(tmp&0x7f)<<21;
//						result |=(tmp=buffer.readByte())<<28;
//						if(tmp<0){
//							for(var i:int=0;i<5;i++){
//								if(buffer.readByte()>=0) return result;
//							}
//						}
//					}
//				}
//			}
//			
//			return result;
		}
		
		public static function writeRawByte(buffer:ByteArray,value:int):void{
			buffer.writeByte(value);
		}
		public static function encodeZigzag32(value:int):int
		{
			return (value<<1)^(value>>31);
		}
		
		public static function decodeZigzag32(value:int):int
		{
			return (value>>>1)^-(value&1);
		}
		
		public static function decodeZigzag64(value:Long):Long
		{ 
			var vA:Long=value.shiftRightUn(1);
			var vB:Long =(value.low&1)==0?Long.ZERO:Long.SIGN;
			return vA.xor(vB);
		}
		
		public static function encodeZigzag64(value:Long):Long
		{
			var vA:Long =value.shiftLeft(1);
			var vB:Long =value.shiftRight(63);
			return vA.xor(vB);
		}
		
	}
}
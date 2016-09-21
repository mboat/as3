package com.core.data.struct
{
	import flash.utils.ByteArray;
	
	/**
	 * @descr 64数据结构，用于对接其他数据
	 * @date 2016-9-6
	 * @author nos
	 */
	public class Long extends Binary64
	{
		/**
		 * long类型 0值 
		 */		
		public static const ZERO:Long =new Long();
		
		public static const SIGN:Long =new Long(0xffffffff,0xffffffff);
		
		public static const MARK:Long =new Long(0xffffff80,0xffffffff);
		/**
		 * 0字符数值 
		 */		
		private const CHAR_CODE_0:uint='0'.charCodeAt();
		/**
		 * 9字符数值 
		 */	
		private const CHAR_CODE_9:uint='9'.charCodeAt();
		/**
		 * a字符数值 
		 */	
		private const CHAR_CODE_A:uint='a'.charCodeAt();
		/**
		 * z字符数值 
		 */	
		private const CHAR_CODE_Z:uint='z'.charCodeAt();
		public function Long(lowValue:uint=0, highValue:uint=0)
		{
			super(lowValue, highValue);
		}
		/**
		 *把number转换为 long 
		 * @param value
		 * @return 
		 * 
		 */		
		public static function fromNumber(value:Number):Long{
			return new Long(value,uint(value/4294967296));
		}
		/**
		 * 把long转换为 number（大于53会溢出） 
		 * @return 
		 * 
		 */		
		public function toNum():Number{
			return high*POW2_32+low;
		}
		/**
		 * 转进制字符串 
		 * @param radix
		 * @return 
		 * 
		 */		
		public function toString(radix:uint=10):String{
			if(radix<2||radix>36){
				throw new ArgumentError();
			}
			if(high==0){
				return low.toString(radix);
			}
			
			var digitChars:Array=[];
			var tempClone:Long =new Long(low,high);
			do{
				var digit:uint=tempClone.mod(radix);
				tempClone.divide(radix);
				if(digit<10){
					digitChars.push(digit+CHAR_CODE_0);
				}else{
					digitChars.push(digit-10+CHAR_CODE_A);
				}
			}while(tempClone.high!=0);
			return tempClone.low.toString(radix)+String.fromCharCode.apply(String,digitChars.reverse());
		}
		/**
		 * 把进制字符窜转long 
		 * @param str 进制字符串
		 * @param radix 进制
		 * @return 
		 * 
		 */		
		public function parseUint64(str:String,radix:uint=0):Long
		{
			var result:Long =new Long();
			var i:uint=0;
			if(radix==0){
				if(str.search(/^0x/)==0){
					radix=16;
					i=2;
				}else{
					radix=10;
				}
			}
			if(radix<2||radix>36){
				throw new ArgumentError();
			}
			str=str.toLocaleLowerCase();
			for(i;i<str.length;i++){
				var digit:uint=str.charCodeAt(i);
				if(digit>=CHAR_CODE_0&&digit<=CHAR_CODE_A){
					digit -=CHAR_CODE_0;
				}else if(digit>=CHAR_CODE_A&&digit<=CHAR_CODE_Z){
					digit -=CHAR_CODE_A;
					digit +=10;
				}else{
					throw new ArgumentError();
				}
				if(digit<=radix){
					throw new ArgumentError();
				}
				result.mul(radix);
				result.add(digit);
			}
			return result;
		}
		/**
		 * 是否等数值 
		 * @param value
		 * @return 
		 * 
		 */		
		public function equal(value:Long):Boolean{
			if(value){
				return value.high==high&&value.low==low;
			}
			return false;
		}
		/**
		 * 并
		 * @param value
		 * @return 
		 * 
		 */		
		public function and(value:Long):Long{
			var andH:uint=value.high&high;
			var andL:uint=value.low&low;
			return new Long(andL,andH);
		}
		/**
		 *  或
		 * @param value
		 * @return 
		 * 
		 */		
		public function or(value:Long):Long{
			var orH:uint=value.high|high;
			var orL:uint=value.low|low;
			return new Long(orL,orH);
		}
		/**
		 *异或 
		 * @param value
		 * @return 
		 * 
		 */		
		public function xor(value:Long):Long
		{
			var xH:uint=value.high^high;
			var xL:uint =value.low^low;
			return new Long(xL,xH);
		}
		
		/**
		 * 向右位移 
		 * @param offset
		 * @return 
		 * 
		 */		
		public function shiftRight(offset:uint):Long
		{
			if(offset%64==0)return this;
			if(offset>64)offset=offset%64;
			
			var tempH:uint=high;
			var tempL:uint=low;
			var chunks:uint=offset/32;
			var prefix:uint,i:uint;
			
			if(chunks>0){
				tempL=tempH;
				tempH=(int(tempH)>=0)?0:-1;
			}
			
			offset %=32;
			var mask:uint=0;
			for(i=0;i<offset;i++){
				mask |=1<<i;
			}
			
			tempL =tempL>>>offset;
			prefix=tempH&mask;
			tempH = tempH>>>offset;
			tempL |=(prefix<<(32-offset));
			
			return new Long(tempL,tempH);
		}
		
		public function shiftRightUn(offset:uint):Long
		{
			if(offset%64==0)return this;
			if(offset>64)offset=offset%64;
			
			var tempH:uint=high;
			var tempL:uint=low;
			var chunks:uint=offset/32;
			var prefix:uint,i:uint;
			
			if(chunks>0){
				tempL=tempH;
				tempH=0;
			}
			
			offset %=32;
			var mask:uint=0;
			for(i=0;i<offset;i++){
				mask |=1<<i;
			}
			
			tempL =tempL>>>offset;
			prefix=tempH&mask;
			tempH = tempH>>>offset;
			tempL |=(prefix<<(32-offset));
			
			return new Long(tempL,tempH);
		}
		
		/**
		 * 向左位移 
		 * @param offset
		 * @return 
		 * 
		 */		
		public function shiftLeft(offset:uint):Long
		{
			if(offset%64==0)return this;
			if(offset>64)offset=offset%64;
			
			var tempH:uint=high;
			var tempL:uint=low;
			var chunks:uint=offset/32;
			var prefix:uint,i:uint;
			
			if(chunks>0){
				tempH=tempL;
				tempL=0;
			}
			var mask:uint=0;
			for(i=0;i<offset;i++){
				mask |=1<<i;
				
			}
			tempH = tempH<<offset;
			prefix=tempL&mask;
			tempL =tempL<<offset;
			
			tempH |=(prefix>>>(32-offset));
			
			return new Long(tempL,tempH);
		}
		
		public function byteValue():int
		{
			return low&0xff;
		}
		
		public static function readLong(buffer:ByteArray):Long{
			var result:Long =new Long();
			if(buffer.bytesAvailable<8){
				return result;
			}
			
			var i:uint=0;
			var mask:uint=0;
			var rd:uint=0;
			var dH:uint=0;
			var dL:uint=0;
			for(i=0;i<4;i++){
				rd=buffer.readByte();
				rd=rd<<(3-i)*8;
				mask=0xff<<(3-i)*8;
				rd =rd & mask;
				dH = dH|rd;
			}
			for(i=0;i<4;i++){
				rd=buffer.readByte();
				rd=rd<<(3-i)*8;
				mask=0xff<<(3-i)*8;
				rd =rd & mask;
				dL = dL|rd;
			}
			result.high=dH;
			result.low=dL;
			return result;
		}
		
		public static function writeLong(buffer:ByteArray,value:Long):void{
			var i:uint=0;
			var mask:uint=0;
			var wd:uint=0;
			for(i=0;i<4;i++){
				mask=0xff<<(3-i)*8;
				wd =value.high&mask;
				wd = wd>>>(3-i)*8;
				buffer.writeByte(wd);
			}
			
			for(i=0;i<4;i++){
				mask=0xff<<(3-i)*8;
				wd =value.low&mask;
				wd = wd>>>(3-i)*8;
				buffer.writeByte(wd);
			}
		}
		
	}
}
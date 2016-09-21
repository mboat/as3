package com.core.data.struct
{
	/**
	 * 
	 * @author nos
	 * 
	 */	
	public class Binary64
	{
		/**
		 *低位值 
		 */		
		public var low:uint=0;
		/**
		 *高位值 
		 */		
		public var high:uint=0;
		/**
		 * 32位值 
		 */		
		public const POW2_32:Number=4294967296;
		public function Binary64(lowValue:uint,HighValue:uint)
		{
			this.low=lowValue;
			this.high=HighValue;
		}
		/**
		 *  
		 * @param value
		 * @return 
		 * 
		 */		
		internal final function mod(value:uint):uint{
			var modHigh:uint=high%value;
			var mod:uint=(low%value+modHigh*POW2_32)%value;
			return mod;
		}
		/**
		 * 加 
		 * @param value
		 * 
		 */		
		internal final function add(value:uint):void{
			var addLow:Number=low+value;
			
			high+=uint(addLow/POW2_32);
			
			low=addLow;
		}
		
		internal final function mul(value:uint):void{
			var mulLow:Number=low*value;
			
			high *=value;
			high +=uint(mulLow/POW2_32);
			
			low=mulLow;
		}
		/**
		 * 除 
		 * @param value
		 * 
		 */		
		internal final function divide(value:uint):void{
			var modHigh:uint=high%value;
			var divLow:Number=(modHigh*POW2_32+low)/value;
			
			high /=value;
			high+=uint(divLow/POW2_32);
			
			low =divLow;
		}
	}
}
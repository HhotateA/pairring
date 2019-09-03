﻿//made by hhotatea
//2018/12/08

    #define keymax 10000
    uniform uint _key;

    float2 memouv_lay(float i){
        float2 output;
        float seed = _key%keymax;
        output.x = frac(seed / 100)+0.005;
        output.y = floor(seed / 100)/100 +lerp(0.0,0.005,step(i,0.5));
        return lerp(0.01,0.99,output);
    }
    
    float2 memouvunpack_lay(int i){
        float2 output;
        float seed = _key%keymax;
        output.x = frac(seed / 100)+0.005;
        output.y = floor(seed / 100)/100 +lerp(0.0,0.005,step(0.5,i));
        return UnityStereoTransformScreenSpaceTex(lerp(0.01,0.99,output));
    }
    
    float2 memouv(){
        float2 output;
        float seed = _key%keymax;
        output.x = frac(seed / 100);
        output.y = floor(seed / 100)/100;
        return lerp(0.01,0.99,output);
    }
    
    float2 memouvunpack(){
        float2 output;
        float seed = _key%keymax;
        output.x = frac(seed / 100);
        output.y = floor(seed / 100)/100;
        return UnityStereoTransformScreenSpaceTex(lerp(0.01,0.99,output));
    }

    float jackR(){
        float output = (2)*1/min(_ScreenParams.x,_ScreenParams.y);
        return output;
    }

    		static float4 jackpos[4] =
			{
				float4(-1.0, 1.0, 0.0, 1.0),
				float4( 1.0,-1.0, 0.0, 1.0),
				float4(-1.0,-1.0, 0.0, 1.0),
				float4( 1.0, 1.0, 0.0, 1.0),
			};

			static float2 jackuv[4] =
			{
				float2( 0.0, 0.0),
				float2( 1.0, 1.0),
				float2( 0.0, 1.0),
				float2( 1.0, 0.0),
			};
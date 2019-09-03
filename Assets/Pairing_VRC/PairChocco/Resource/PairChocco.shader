//2019/01/11
//@HHOTATEA_VRC
Shader "HOTATE/PairChocco"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_key ("key(0~9999)",float) = 0
		_slider ("",Range(0.0,1.0)) = 0.0
		_rotationaxis1 ("Rotation1" , VECTOR) = (0.0,  0.0,0.0,0.0)
		_rotationaxis2 ("Rotation2" , VECTOR) = (0.0,180.0,0.0,0.0)
		_ofset ("Ofset",Vector) = (0.0,0.05,0.0,0.0)
		[Space(10)]
		[Toggle(ForceRotation)] _ForceRotation ("ForceRotation",float) = 0.0
		_rotation ("Rotation" , Vector) = (0.0,0.0,0.0,0.0)
	}
	SubShader
	{
		Tags {"RenderType"="Opaque" "Queue" = "Overlay-502"}
		LOD 100
		Stencil {
            Ref 11
            Comp NotEqual
            Pass keep
        }

		GrabPass {}
		Pass
		{
			CGPROGRAM

			#pragma shader_feature ForceRotation

			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			#define keymax 10000
			uniform uint _key;
			uniform float _slider;
			float4 _rotationaxis1;
			float4 _rotationaxis2;
			float4 _ofset;
			float4 _rotation;

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

			
			// Taken from http://answers.unity.com/answers/641391/view.html
			// Creates inverse matrix of input
			float4x4 inverse(float4x4 input)
			{
				#define minor(a,b,c) determinant(float3x3(input.a, input.b, input.c))
				float4x4 cofactors = float4x4(
					minor(_22_23_24, _32_33_34, _42_43_44), 
					-minor(_21_23_24, _31_33_34, _41_43_44),
					minor(_21_22_24, _31_32_34, _41_42_44),
					-minor(_21_22_23, _31_32_33, _41_42_43),

					-minor(_12_13_14, _32_33_34, _42_43_44),
					minor(_11_13_14, _31_33_34, _41_43_44),
					-minor(_11_12_14, _31_32_34, _41_42_44),
					minor(_11_12_13, _31_32_33, _41_42_43),

					minor(_12_13_14, _22_23_24, _42_43_44),
					-minor(_11_13_14, _21_23_24, _41_43_44),
					minor(_11_12_14, _21_22_24, _41_42_44),
					-minor(_11_12_13, _21_22_23, _41_42_43),

					-minor(_12_13_14, _22_23_24, _32_33_34),
					minor(_11_13_14, _21_23_24, _31_33_34),
					-minor(_11_12_14, _21_22_24, _31_32_34),
					minor(_11_12_13, _21_22_23, _31_32_33)
				);
				#undef minor
				return transpose(cofactors) / determinant(input);
			}

			float3x3 rotationmatrix(float3 input){
				float3 axis = input * 2*3.14159265358979 / 360 ;
				float3x3 rotationx = {
									              1,           0,           0,
										          0, cos(axis.x),-sin(axis.x),
									              0, sin(axis.x), cos(axis.x),
									 };
				float3x3 rotationy = {
									   cos(axis.y),            0, sin(axis.y),
									             0,            1,           0,
									  -sin(axis.y),            0, cos(axis.y),
									 };
				float3x3 rotationz = {
									   cos(axis.z),-sin(axis.z),            0,
									   sin(axis.z), cos(axis.z),            0,
									             0,           0,            1,
									 };
				return mul(rotationz,mul(rotationx,rotationy));
			}

			float4x4 scalematrix(float3 scale){
				float4x4 returnmatrix = {
									          scale.x,           0,            0,            0,
									                0,     scale.y,            0,            0,
									                0,           0,      scale.z,            0,
									                0,           0,            0,          1.0,
									    };
				return returnmatrix;
			}

			float3 vrccamerapos(){
				float3 cameraPos = _WorldSpaceCameraPos;
				#if defined(USING_STEREO_MATRICES)
				cameraPos = (unity_StereoWorldSpaceCameraPos[0] + unity_StereoWorldSpaceCameraPos[1]) * 0.5;
				#endif
				return cameraPos;
			} 

			float3 calcscale(){
				float sX = sqrt(unity_ObjectToWorld[0].x * unity_ObjectToWorld[0].x + unity_ObjectToWorld[0].y * unity_ObjectToWorld[0].y + unity_ObjectToWorld[0].z * unity_ObjectToWorld[0].z);
				float sY = sqrt(unity_ObjectToWorld[1].x * unity_ObjectToWorld[1].x + unity_ObjectToWorld[1].y * unity_ObjectToWorld[1].y + unity_ObjectToWorld[1].z * unity_ObjectToWorld[1].z);
				float sZ = sqrt(unity_ObjectToWorld[2].x * unity_ObjectToWorld[2].x + unity_ObjectToWorld[2].y * unity_ObjectToWorld[2].y + unity_ObjectToWorld[2].z * unity_ObjectToWorld[2].z);
				return float3(sX,sY,sZ);
			}

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _GrabTexture;
			
			v2f vert (appdata v)
			{
				v2f o;
				
				float4 pos1 = tex2Dlod(_GrabTexture,float4(memouvunpack_lay(0.0),0.0,0.0)); pos1 = mul(inverse(UNITY_MATRIX_V),pos1);
				float4 pos2 = tex2Dlod(_GrabTexture,float4(memouvunpack_lay(1.0),0.0,0.0)); pos2 = mul(inverse(UNITY_MATRIX_V),pos2);
				float4 vpos = lerp(pos1,pos2,_slider);
				vpos = float4(vpos.xyz/vpos.w,1.0);
				vpos = mul(inverse(UNITY_MATRIX_M),vpos);
				

				float4 pos = float4(0.0,0.0,0.0,1.0);
				float3 linevec = normalize(pos1-pos2);
				float4 axis = lerp(_rotationaxis1,_rotationaxis2,_slider);
					#ifdef ForceRotation
						pos.xyz = mul(scalematrix(calcscale()),v.vertex.xyz);
						pos.xyz = mul(rotationmatrix(_rotation),pos.xyz);
					#else
						pos.xyz = mul((float3x3)UNITY_MATRIX_M,v.vertex.xyz);
					#endif
				pos.xyz = mul(rotationmatrix( float3( axis.x, degrees(atan2(linevec.x, linevec.z))+axis.y, axis.z )), pos);
				//pos.xyz += mul(UNITY_MATRIX_M,float4(0.0,0.0,0.0,1.0)).xyz;
				pos.xyz += mul(UNITY_MATRIX_M,vpos).xyz;

				pos.xyz += _ofset;

				float4 buf = tex2Dlod(_GrabTexture,float4(memouvunpack(),0.0,0.0));
				fixed finalbuf = lerp(0.0,1.0,step(1-0.001,buf.r));

				pos *= finalbuf;
				
				pos = mul(UNITY_MATRIX_V,pos);
				pos = mul(UNITY_MATRIX_P,pos);
				o.vertex = pos;
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex, i.uv);
				return col;
			}
			ENDCG
		}
	}
}

//made by hhotatea
//2018/12/08
Shader "HOTATE/Pairing/Gem"
{
	Properties
	{
		_key ("key(0~9999)",float) = 0
		[Space(200)]
		_color1 ("Color1", COLOR) = (0.0,0.3,0.4,1.0)
		_color2 ("Color2", COLOR) = (1.0,0.0,0.0,1.0)
		_RimEffect ("リムの強さ",Range(0,1)) = 0
        _RimColor ("リムの色", Color) = (0.0,0.0,0.0,1.0)
		_halopower ("オーラの強さ(最大)",Range(0,10)) = 1.5
		_halopowermin ("オーラの強さ(最小)",Range(0,10)) = 0.9
		_holocolor ("オーラの色",COLOR) = (1.0,0.0,0.0,1.0)
		_pow ("発光調節",float ) = 50
		_noise ("Noise調節(xyz/alpha)",VECTOR) = (200,200,200,0.8)
		[HideInInspector]_seido ("精度調節",float) = 0.01
	}
	SubShader
	{
		Tags {"RenderType"="Opaque" "Queue" = "Overlay-2"}
		LOD 100
		Stencil {
            Ref 11
            Comp NotEqual
            Pass keep
        }

		//moyo
		Pass
		{
			Blend SrcAlpha OneMinusSrcAlpha
			Cull front
			ZWrite off
			ZTest LEqual
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			#include "pairingHelper.cginc"

			uniform float4 _noise;

			// Noise Shader Library for Unity - https://github.com/keijiro/NoiseShader
			//
			// Original work (webgl-noise) Copyright (C) 2011 Stefan Gustavson
			// Translation and modification was made by Keijiro Takahashi.

			float3 mod(float3 x, float3 y){
				return x - y * floor(x / y);
			}

			float3 mod289(float3 x){
				return x - floor(x / 289.0) * 289.0;
			}

			float4 mod289(float4 x){
				return x - floor(x / 289.0) * 289.0;
			}

			float4 permute(float4 x){
				return mod289(((x*34.0)+1.0)*x);
			}

			float4 taylorInvSqrt(float4 r){
				return (float4)1.79284291400159 - r * 0.85373472095314;
			}

			float3 fade(float3 t) {
				return t*t*t*(t*(t*6.0-15.0)+10.0);
			}

			// Classic Perlin noise
			float cnoise(float3 P){
				float3 Pi0 = floor(P); // Integer part for indexing
				float3 Pi1 = Pi0 + (float3)1.0; // Integer part + 1
				Pi0 = mod289(Pi0);
				Pi1 = mod289(Pi1);
				float3 Pf0 = frac(P); // Fractional part for interpolation
				float3 Pf1 = Pf0 - (float3)1.0; // Fractional part - 1.0
				float4 ix = float4(Pi0.x, Pi1.x, Pi0.x, Pi1.x);
				float4 iy = float4(Pi0.y, Pi0.y, Pi1.y, Pi1.y);
				float4 iz0 = (float4)Pi0.z;
				float4 iz1 = (float4)Pi1.z;

				float4 ixy = permute(permute(ix) + iy);
				float4 ixy0 = permute(ixy + iz0);
				float4 ixy1 = permute(ixy + iz1);

				float4 gx0 = ixy0 / 7.0;
				float4 gy0 = frac(floor(gx0) / 7.0) - 0.5;
				gx0 = frac(gx0);
				float4 gz0 = (float4)0.5 - abs(gx0) - abs(gy0);
				float4 sz0 = step(gz0, (float4)0.0);
				gx0 -= sz0 * (step((float4)0.0, gx0) - 0.5);
				gy0 -= sz0 * (step((float4)0.0, gy0) - 0.5);

				float4 gx1 = ixy1 / 7.0;
				float4 gy1 = frac(floor(gx1) / 7.0) - 0.5;
				gx1 = frac(gx1);
				float4 gz1 = (float4)0.5 - abs(gx1) - abs(gy1);
				float4 sz1 = step(gz1, (float4)0.0);
				gx1 -= sz1 * (step((float4)0.0, gx1) - 0.5);
				gy1 -= sz1 * (step((float4)0.0, gy1) - 0.5);

				float3 g000 = float3(gx0.x,gy0.x,gz0.x);
				float3 g100 = float3(gx0.y,gy0.y,gz0.y);
				float3 g010 = float3(gx0.z,gy0.z,gz0.z);
				float3 g110 = float3(gx0.w,gy0.w,gz0.w);
				float3 g001 = float3(gx1.x,gy1.x,gz1.x);
				float3 g101 = float3(gx1.y,gy1.y,gz1.y);
				float3 g011 = float3(gx1.z,gy1.z,gz1.z);
				float3 g111 = float3(gx1.w,gy1.w,gz1.w);

				float4 norm0 = taylorInvSqrt(float4(dot(g000, g000), dot(g010, g010), dot(g100, g100), dot(g110, g110)));
				g000 *= norm0.x;
				g010 *= norm0.y;
				g100 *= norm0.z;
				g110 *= norm0.w;

				float4 norm1 = taylorInvSqrt(float4(dot(g001, g001), dot(g011, g011), dot(g101, g101), dot(g111, g111)));
				g001 *= norm1.x;
				g011 *= norm1.y;
				g101 *= norm1.z;
				g111 *= norm1.w;

				float n000 = dot(g000, Pf0);
				float n100 = dot(g100, float3(Pf1.x, Pf0.y, Pf0.z));
				float n010 = dot(g010, float3(Pf0.x, Pf1.y, Pf0.z));
				float n110 = dot(g110, float3(Pf1.x, Pf1.y, Pf0.z));
				float n001 = dot(g001, float3(Pf0.x, Pf0.y, Pf1.z));
				float n101 = dot(g101, float3(Pf1.x, Pf0.y, Pf1.z));
				float n011 = dot(g011, float3(Pf0.x, Pf1.y, Pf1.z));
				float n111 = dot(g111, Pf1);

				float3 fade_xyz = fade(Pf0);
				float4 n_z = lerp(float4(n000, n100, n010, n110), float4(n001, n101, n011, n111), fade_xyz.z);
				float2 n_yz = lerp(n_z.xy, n_z.zw, fade_xyz.y);
				float n_xyz = lerp(n_yz.x, n_yz.y, fade_xyz.x);
				return 2.2 * n_xyz;
			}

			float fBm (float3 st) {
				float f = 0;
				float3 q = st;

				f += 0.5000*cnoise( q ); q = q*2.01;
				f += 0.2500*cnoise( q ); q = q*2.02;
				f += 0.1250*cnoise( q ); q = q*2.03;
				f += 0.0625*cnoise( q ); q = q*2.01;

				return f;
			}

			struct appdata
			{
				float4 vertex : POSITION;
				float4 uv : TEXCOORD0;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float2 uv : TEXCOORD0;
				float3 modelpos : TEXCOORD1;
			};
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.modelpos = v.vertex;
				o.uv = v.uv;
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed noise = fBm(float3(i.modelpos.x*_noise.x,i.modelpos.y*_noise.y,i.modelpos.z*_noise.z)).x;
				fixed4 col = fixed4(noise,noise,noise,_noise.w);
				return col;
			}
			ENDCG
		}
		
		//maincolor
		GrabPass {}
		Pass
		{
			Blend One One
			Cull off
			ZWrite OFF
			ZTest LEqual 
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			#include "pairingHelper.cginc"

			uniform float4 _color;
			uniform float4 _color1;
			uniform float4 _color2;
			uniform float _RimEffect;
			uniform float4 _RimColor;
			uniform float _seido;
			sampler2D _GrabTexture;


			struct v2f
			{
				float4 vertex : SV_POSITION;
                float3 normal : NORMAL;
                float3 viewDir : TEXCOORD1;
			};
			
			v2f vert (appdata_full v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
                o.normal = normalize(mul((float3x3)unity_ObjectToWorld, v.normal.xyz));
                o.viewDir = normalize(_WorldSpaceCameraPos - mul((float3x3)unity_ObjectToWorld, v.vertex.xyz));
				return o;
			}

			fixed4 frag (v2f i) : SV_Target
			{
				float4 buf = tex2Dlod(_GrabTexture,float4(memouvunpack(),0.0,0.0));
				fixed4 finalcolor = lerp(_color1,_color2,step(1-_seido,buf.r));
				fixed4 col = clamp(fixed4(finalcolor.rgb,0.0),0,1);
                float val = 1-abs(dot(i.viewDir, i.normal)) * _RimEffect;
                col += _RimColor * _RimColor.a * val * val;
				return col;
			}
			ENDCG
		}
		
		//holo
		Pass
		{
			Blend One One
			Cull off
			ZWrite OFF
			ZTest Always
			CGPROGRAM
			#pragma vertex vert
            #pragma geometry geom
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			#include "pairingHelper.cginc"
			#define SQRT3 1.7320508075688772935274463415059

			uniform float4 _color;
			uniform float4 _color1;
			uniform float4 _color2;
			uniform float _seido;
			uniform float _halopower;
			uniform float _halopowermin;
			uniform float4 _holocolor;
			uniform float _pow;
			sampler2D _GrabTexture;

			struct appdata
			{
				float4 vertex : POSITION;
			};

			struct v2g
			{
				float4 vertex : SV_POSITION;
			};

			struct g2f
			{
				float4 vertex : SV_POSITION;
				float4 wPos : TEXCOORD0;
			};
			
			v2g vert (appdata v)
			{
				v2g o;
				o.vertex = v.vertex;
				return o;
			}
 
            [maxvertexcount(3)]
            void geom(triangle v2g input[3], uint primID : SV_PrimitiveID, inout TriangleStream<g2f> output)
            {
                g2f o[3] = (g2f[3])0;

				float4 buf = tex2Dlod(_GrabTexture,float4(memouvunpack(),0.0,0.0));
				float weight = lerp(1.0,0.80,saturate((buf.g*100-2)/20));
				fixed4 holo = lerp(0,_halopower*weight,step(1-_seido,buf.r));
				

				float4 cp = mul(UNITY_MATRIX_M,float4(0.0,0.0,0.0,1.0));
				o[0].wPos = float4(float2(-SQRT3, -1.0)*holo, 0.0, 0.0);
				o[1].wPos = float4(float2(0.0, 2.0)*holo, 0.0, 0.0);
				o[2].wPos = float4(float2(SQRT3, -1.0)*holo, 0.0, 0.0);

				for(int i; i < 3; i++){
					o[i].vertex = mul(UNITY_MATRIX_P, mul(UNITY_MATRIX_V, cp) + o[i].wPos);
					if(primID > 0.1){ o[i].vertex = (0.0,0.0,0.0,0.0);}
					output.Append(o[i]);
				}
				output.RestartStrip();
            }

			fixed4 frag (g2f i) : SV_Target
			{
				float4 buf = tex2Dlod(_GrabTexture,float4(memouvunpack(),0.0,0.0));
				float weight = lerp(_halopower,_halopowermin,saturate((buf.g*100-2)/20));
				fixed4 holo = lerp(0,weight,step(1-_seido,buf.r));
				fixed4 col = _holocolor ;
				float d = length(i.wPos.xy)/holo * 1/(buf.g * 100);
				clip(holo-length(i.wPos.xy));
				col = lerp(float4(0,0,0,0),col,pow(holo-length(i.wPos.xy),_pow));
				return float4(col.rgb, clamp(0.5 - pow(d,2) + 0, 0.0, 1.0));
			}
			ENDCG
		}
		
	}
}

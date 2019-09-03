//made by hhotatea
//2018/12/08
Shader "HOTATE/Pairing/VertexPass_himo"
{
	Properties
	{
		_key ("key(0~9999)",float) = 0
		[Toggle]_pair ("PairSwitch",Int) = 0
		[HideInInspector]_dist ("最長レイ距離",float) = 100
		[HideInInspector]_ninzuu ("セット人数",Float) = 2
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" "Queue" = "Overlay-603"}
		LOD 100
		ZWrite off
		ZTest always
		Blend One Zero
		Cull off

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			#include "pairingHelper_himo.cginc"

			uniform float _ninzuu;
			uniform float _dist;
			uniform int _pair;



			struct appdata
			{
				float4 vertex : POSITION;
				uint   vID	  : SV_VertexID;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float2 uv : TEXCOORD0;
			};
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = jackpos[v.vID];
				o.uv = jackuv[v.vID];
				return o;
			}
			
			float4 frag (v2f i) : SV_Target
			{
				clip(jackR()-distance(memouv_lay(_pair),i.uv));	
				float4 col = mul(UNITY_MATRIX_MV,float4(0,0,0,1))/_dist;
				float4 vec = normalize(col);
				float4 output = lerp(col,vec,any(uint3(step(col.r,1),step(col.g,1),step(col.b,1))));
				return output;
			}
			ENDCG
		}
		
		Pass
		{
			Blend One One
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			#include "pairingHelper_himo.cginc"

			uniform float _ninzuu;

			struct appdata
			{
				float4 vertex : POSITION;
				uint   vID	  : SV_VertexID;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float2 uv : TEXCOORD0;
			};
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = jackpos[v.vID];
				o.uv = jackuv[v.vID];
				return o;
			}
			
			float4 frag (v2f i) : SV_Target
			{
				float4 col = float4(float3(1.0,0.0,0.0)/_ninzuu,0.0);
				col.g = distance(_WorldSpaceCameraPos,mul(UNITY_MATRIX_M,float4(0,0,0,1)))/100;
				clip(jackR()-distance(memouv(),i.uv));
				return col;
			}
			ENDCG
		}
	}
}

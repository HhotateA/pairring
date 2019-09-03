//made by hhotatea
//2018/12/08
Shader "HOTATE/Pairing/ColorReset"
{
	Properties
	{
		_key ("key(0~9999)",float) = 0
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" "Queue" = "Overlay-1"}
		LOD 100
		ZWrite off
		ZTest always
		Blend One Zero
		Cull off

		GrabPass {}
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			#include "pairingHelper.cginc"

			sampler2D _GrabTexture;

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
				float2 grabuv = memouvunpack();
				grabuv.x += jackR()*2;
				float4 col = tex2Dlod(_GrabTexture,float4(grabuv,0.0,0.0));
				clip(jackR()-distance(memouv(),i.uv));
				return col;
			}
			ENDCG
		}
	}
}

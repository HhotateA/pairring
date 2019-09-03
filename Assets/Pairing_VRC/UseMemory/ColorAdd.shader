//made by hhotatea
//2018/12/08
Shader "HOTATE/Pairing/ColorAdd"
{
	Properties
	{
		_key ("key(0~9999)",float) = 0
		[HideInInspector]_ninzuu ("セット人数",Float) = 2
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" "Queue" = "Overlay-3"}
		LOD 100
		ZWrite off
		ZTest always
		Blend ONE ONE
		Cull off

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			#include "pairingHelper.cginc"

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

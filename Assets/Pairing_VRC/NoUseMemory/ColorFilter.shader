//made by hhotatea
//2018/12/08
Shader "HOTATE/Pairing/ColorAdd"
{
	Properties
	{
		_Stencil ("key(10~255)", Float) = 0
		_color ("HoloColor",Color) = (1.0,0.0,0.0,1.0)
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" "Queue" = "Overlay-1"}
		LOD 100
		ZWrite off
		ZTest always
		Blend ONE ONE
		Cull off
		Stencil {
            Ref [_Stencil]
            Comp Equal
            Pass Keep
        }

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			uniform float4 _color;

			static float4 jackpos[4] =
			{
				float4(-1.0, 1.0, 0.0, 1.0),
				float4( 1.0,-1.0, 0.0, 1.0),
				float4(-1.0,-1.0, 0.0, 1.0),
				float4( 1.0, 1.0, 0.0, 1.0),
			};

			struct appdata
			{
				float4 vertex : POSITION;
				uint   vID	  : SV_VertexID;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
			};

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = jackpos[v.vID];
				return o;
			}

			float4 frag (v2f i) : SV_Target
			{
				return _color;
			}
			ENDCG
		}
	}
}

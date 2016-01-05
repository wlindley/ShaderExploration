Shader "Test/GlassShader"
{
	Properties
	{
		_AlphaMap("AlphaMap", 2D) = "white" {}
		_Color("Glass Color", Color) = (1, 1, 1, 1)
		_BumpMap("Noise texture", 2D) = "bump" {}
		_BumpMagnitude("Noise Amount", Range(0,1)) = .05
	}

	SubShader
	{
		Tags { "RenderType"="Opaque" "Queue"="Transparent" "IgnoreProjector"="True" }
		ZWrite On Lighting Off Cull Off Fog { Mode Off } Blend One Zero
		LOD 100

		GrabPass { "_GrabTexture" }

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float2 uv : TEXCOORD0;
				float4 grabUV : TEXCOORD1;
			};

			half4 _Color;
			sampler2D _GrabTexture;
			sampler2D _BumpMap;
			float _BumpMagnitude;
			sampler2D _AlphaMap;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
				o.uv = v.uv;
				o.grabUV = ComputeGrabScreenPos(o.vertex);
				return o;
			}
			
			half4 frag (v2f i) : COLOR
			{
				float4 diffuse = tex2D(_AlphaMap, i.uv);
				half4 bump = tex2D(_BumpMap, i.uv);
				half2 distortion = UnpackNormal(bump).rg;
				i.grabUV.xy += distortion * _BumpMagnitude;
				fixed4 col = tex2Dproj(_GrabTexture, UNITY_PROJ_COORD(i.grabUV));
				return col * _Color * diffuse;
			}
			ENDCG
		}
	}
}

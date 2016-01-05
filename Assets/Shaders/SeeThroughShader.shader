Shader "Test/SeeThroughShader"
{
	Properties
	{
		_MainTex("MainTexture", 2D) = "white" {}
		_Color("Color", Color) = (1, 1, 1, 1)
		_VisibilityMap("VisibilityMap", 2D) = "white" {}
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque" "Queue" = "Transparent" "IgnoreProjector" = "True" }
		ZWrite On Lighting Off Cull Off Fog{ Mode Off } Blend One Zero
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
				float3 normal : NORMAL;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float2 uv : TEXCOORD0;
				float3 normal : NORMAL;
				float4 grabUV : TEXCOORD1;
			};

			sampler2D _MainTex;
			float4 _LightColor0;
			half4 _Color;
			sampler2D _VisibilityMap;
			sampler2D _GrabTexture;
			float4 _MainTex_ST;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
				o.normal = mul(float4(v.normal, 0.0), _Object2World).xyz;
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.grabUV = ComputeGrabScreenPos(o.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 texCol = tex2D(_MainTex, i.uv) * _Color;
				float3 normalDir = normalize(i.normal);
				float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
				float3 diffuse = _LightColor0.rgb * max(0.0, dot(normalDir, lightDir));
				return texCol * float4(diffuse, 1);
				/*
				float visibility = tex2D(_VisibilityMap, i.uv).a;

				float4 grabCol = tex2Dproj(_GrabTexture, UNITY_PROJ_COORD(i.grabUV));
				
				if (visibility < .5)
					return grabCol;
				
				return texCol * float4(diffuse, 1);
				//return (texCol * float4(1, 1, 1, visibility)) + (grabCol * float4(1, 1, 1, 1 - visibility));
				*/
			}
			ENDCG
		}
	}
}

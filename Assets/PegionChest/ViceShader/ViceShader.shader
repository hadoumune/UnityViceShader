Shader "PegionChest/ViceShader"
{
	Properties { _MainTex ("Texture", 2D) = "white" {} }

	SubShader
	{
		Tags
		{
			"RenderType"="Background"
			"Queue"="Background"
			"PreviewType"="SkyBox"
		}

		Pass
		{
			ZWrite Off
			Cull Off

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float3 rayDir : TEXCOORD0;
			};

			struct v2f 
			{
				float4 vertex : SV_POSITION;
				float3 rayDir : TEXCOORD0;
				float4 pos: TEXCOORD1;
			};

			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.rayDir = v.rayDir;
				o.pos = ComputeScreenPos(o.vertex);
				return o;
			}

			#include "ViceFunc.cginc"
			sampler2D _MainTex;
            float4 _MainTex_ST;

			float4 vice(float3 cameraPos, float3 rayDir, float4 screenPos)
			{
				float4 c = float4(1, 0, 0, 1);
				float2 st = screenPos.xy/screenPos.w;
				//return osc(st,75,0.05,0);
				//return mult(osc(rotate(st, 0.5, 0),100,0.05,0),shape(repeat(st, 20, 16, 0, 0),12,0.1,0),1);
				//return shape(st,12,0.1,0.5);
				float4 o0 = tex2D(_MainTex,st);
				float st2 = modulate(
					rotate(st,-0.5, -0.5),
					shape(
						repeatY(
							modulate(
								repeatX(
									scale(
										rotate(st,0.5, 0.5),
										1,1,1,0,0
									),
									2,2
								),
								o0, 0.5
							),
							2, 2
						),
						4,0.75,0
					),
					0.5
				);
				o0 = tex2D(_MainTex,st2);
				return blend(color(osc(st2,8,-0.5, 1),-1.5, -1.5, -1.5,1.0),o0,0.75);
				//return osc(st2,8,-0.5,1);
				/*
				return
					mult(
						add(
							color(
								thresh(
									osc(
										rotate(st, 0.5, 0),
										10, 0.1, 0
									),
									0.5, 0
								),
								0.755, 1, 0, 1
							),
							thresh(
								osc(
									rotate(st, 0.8, 0),
									10, 0.1, 0
								),
								0, 0
							),
							1
						),
						shape(
							repeat(st, 20, 16, 0, 0),
							12, 0.1, 0
						),
						1
					);
					*/
			}

			fixed4 frag (v2f i) : SV_TARGET
			{
				float3 rayDir = normalize(i.rayDir);
				return vice(_WorldSpaceCameraPos,rayDir,i.pos);
			}

			ENDCG
		}
	}
}
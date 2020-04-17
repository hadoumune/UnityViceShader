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

			float4 vice(float3 cameraPos, float3 rayDir, float4 screenPos, float4 st)
			{
				float4 c = float4(1, 0, 0, 1);
				//return osc(st,75,0.05,0);
				//return mult(osc(rotate(st, 0.5, 0),100,0.05,0),shape(repeat(st, 20, 16, 0, 0),12,0.1,0),1);
				//return shape(st,12,0.1,0.5);
				float4 o0 = tex2D(_MainTex,rotate(st,-0.5,-0.5));
				//o0 = tex2D(_MainTex,st);
				return blend(color(osc(rotate(st,-0.5,-0.5),8,-0.5, 1),-1.5, -1.5, -1.5,1.0),o0,0.750);
			}

			fixed4 frag (v2f i) : SV_TARGET
			{
				float3 rayDir = normalize(i.rayDir);
				float2 st = i.pos.xy/i.pos.w;
				return vice(_WorldSpaceCameraPos,rayDir,i.pos,st);
			}

			ENDCG
		}
	}
}
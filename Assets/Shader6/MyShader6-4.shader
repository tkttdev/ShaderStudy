// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/MyShader6-4" {
	Properties{
		_Texture("Texture", 2D) = "white"{}
	}
	SubShader {
		Pass {
			Tags { "LightMode" = "ForwardBase" }
			CGPROGRAM
			#pragma multi_compile_fwdbase
			#pragma vertex vert
			#pragma fragment frag
			#pragma fragmentoption ARB_precision_hint_fastest
			#include "UnityCG.cginc"
			#include "AutoLight.cginc"

			float4 _LightColor0;
			sampler2D _Texture;
			float4 _Texture_ST;
			struct vertout {
				 float4 pos : SV_POSITION;
				 float2 TexCoord :TEXCOORD0;
				 float3 Normal : TEXCOORD2;
				 float3 lightDir : TEXCOORD3;
				 float3 viewDir : TEXCOORD4;

				 LIGHTING_COORDS(5, 6)
			};

			vertout vert(appdata_full v){
				vertout OUT;
				OUT.pos = UnityObjectToClipPos(v.vertex);
				OUT.TexCoord = TRANSFORM_TEX(v.texcoord, _Texture);
				OUT.Normal = normalize(v.normal).xyz;
				OUT.lightDir = normalize(ObjSpaceLightDir(v.vertex));
				OUT.viewDir = normalize(ObjSpaceViewDir(v.vertex));

				TRANSFER_VERTEX_TO_FRAGMENT(OUT);
				return OUT;
			}

			fixed4 frag(vertout In) : COLOR{
				fixed atten = LIGHT_ATTENUATION(In);
				float diffuse = max(0, mul(In.lightDir, In.Normal));
				float specular = max(0, mul(normalize(In.viewDir + In.lightDir), In.Normal));
				specular = pow(specular, 30);
				float4 tex = tex2D(_Texture, In.TexCoord);
				float4 color = tex * UNITY_LIGHTMODEL_AMBIENT + (tex * _LightColor0 * diffuse + _LightColor0 * half4(1.0,1.0,1.0,1.0) * specular) * atten;
				return color;
			}
			ENDCG
		}
	}
	FallBack "Diffuse"
}

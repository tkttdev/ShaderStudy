﻿Shader "Custom/MyShader6-7" {
	Properties {
		_Diffuse("Diffuse Color", Color) = (0.5, 0.5, 0.5, 1.0)
		_Bump("Bump", 2D) = "white"{}
		_Cubemap("Cubemap", CUBE) = ""{}
	}
	SubShader {
		Pass {
			Tags{"LightMode" = "ForwardBase"}
			CGPROGRAM
			#pragma multi_complie_fwdbase
			#pragma vertex vert
			#pragma fragment frag
			#pragma fragmentoption ARB_precision_hint_fastest
			#include "UnityCG.cginc"
			#include "AutoLight.cginc"
			float4 _LightColor0;
			float4 _Diffuse;
			sampler2D _Bump;
			float4 _Bump_ST;
			samplerCUBE _Cubemap;

			struct vertout {
				float4 pos : SV_POSITION;
				float2 TexCoord : TEXCOORD0;
				float3 lightDir : TEXCOORD1;
				float3 viewDir : TEXCOORD2;
				float4 TangentRX : TEXCOORD3;
				float4 TangentRY : TEXCOORD4;
				float4 TangentRZ : TEXCOORD5;

				LIGHTING_COORDS(6, 7) 
			};

			vertout vert(appdata_full v){
				vertout OUT;
				OUT.pos = UnityObjectToClipPos(v.vertex);
				OUT.TexCoord = TRANSFORM_TEX(v.texcoord, _Bump);

				TANGENT_SPACE_ROTATION;

				OUT.TangentRX.xyz = mul(rotation, unity_ObjectToWorld[0].xyz);
				OUT.TangentRY.xyz = mul(rotation, unity_ObjectToWorld[1].xyz);
				OUT.TangentRZ.xyz = mul(rotation, unity_ObjectToWorld[2].xyz);

				OUT.lightDir = normalize(ObjSpaceLightDir(v.vertex));
				OUT.viewDir = normalize(ObjSpaceViewDir(v.vertex));

				TRANSFER_VERTEX_TO_FRAGMENT(OUT)


				return OUT;
			}

			fixed4 frag(vertout In) : COLOR {
				fixed atten = LIGHT_ATTENUATION(In);
				float3 bumpNormal = UnpackNormal(tex2D(_Bump, In.TexCoord));
				float3 normal;
				normal.x = dot(In.TangentRX, bumpNormal);
				normal.y = dot(In.TangentRY, bumpNormal);
				normal.z = dot(In.TangentRZ, bumpNormal);

				float diffuse = max(0, mul(normalize(In.viewDir + In.lightDir), normal));
				float specular = max(0, mul(normalize(In.viewDir + In.lightDir), normal));
				specular = pow(specular, 30);

				float4 reflectVec;
				reflectVec.xyz = reflect(-In.viewDir, normal);
				reflectVec.w = 1;
				float4 reflectColor = texCUBE(_Cubemap, reflectVec);

				float4 refractVec;
				refractVec.xyz = refract(In.viewDir, normal, 0.667);
				refractVec.w = 1;
				float4 refractColor = texCUBE(_Cubemap, refractVec);
				float4 reflectPower = pow(dot(In.viewDir, normal), 3);
				float4 refractPower = pow(1.0 - dot(In.viewDir, normal), 1.5);
				float4 color = UNITY_LIGHTMODEL_AMBIENT + _Diffuse * _LightColor0 * (diffuse + 1)/2;
				color *= (refractPower + 1) / 2;
				color += _LightColor0 * half4(1.0, 1.0, 1.0, 1.0) * specular;
				color += reflectPower * refractColor + refractPower * reflectColor;
				return color;
			}
			ENDCG
		}
	}
	FallBack "Diffuse"
}

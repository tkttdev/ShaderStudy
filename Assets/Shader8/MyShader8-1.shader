// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/MyShader8-1" {
	Properties {
		_Diffuse("Diffuse Color", COLOR) = (0.5,0.5,0.5,1.0)
		_DispTex("Disp Texture", 2D) = "gray"{}
		_Displacement("Displacement", Range(0, 0.2)) = 0.1
	}
	SubShader {
		Pass{
			Tags{"LightMode" = "ForawardBase"}
			CGPROGRAM
			#pragma multi_complie_fwdbase
			#pragma vertex vert
			#pragma hull hul
			#pragma domain dom
			#pragma fragment frag
			#pragma fragmentoption ARB_precision_hint_fastest
			#include "UnityCG.cginc"
			#include "AutoLight.cginc"
			#include "Tessellation.cginc"

			float4 _LightColor0;
			float4 _Diffuse;
			float _Displacement;
			sampler2D _DispTex;
			float4 _DispTex_ST;

			struct vertout{
				float4 pos:POSITION;
				float3 texcoord:TEXCOORD0;
				float3 Normal:TEXCOORD1; 
			};

			struct constant_hsout{
				float tessFactor[3]:SV_TessFactor;
				float insideFactor:SV_InsideTessFactor;
			};

			struct hsout{
				float3 pos:TEXCOORD0;
				float3 texcoord:TEXCOORD1;
				float3 Normal:TEXCOORD2; 
			};

			struct dsout{
				float4 pos:SV_POSITION;
				float3 Normal:TEXCOORD0;
				float3 lightDir:TEXCOORD1;
				float3 viewDir:TEXCOORD2;
				LIGHTING_COORDS(3,4) 
			};

			vertout vert(appdata_full v){
				vertout OUT;
				OUT.pos = v.vertex;
				OUT.texcoord = v.texcoord;
				OUT.Normal = normalize(v.normal).xyz;
				return OUT;
			}

			constant_hsout ConstantsHull(InputPatch<vertout, 3> iPatch){
				constant_hsout OUT;
				float minDistance = 1;
				float maxDistance = 5;
				float maxFactor = 10;
				float4 factor = UnityDistanceBasedTess(iPatch[0].pos, iPatch[1].pos, iPatch[2].pos, minDistance, maxDistance, maxFactor);
				OUT.tessFactor[0] = factor[0];
				OUT.tessFactor[1] = factor[1];
				OUT.tessFactor[2] = factor[2];
				OUT.insideFactor = factor[3];
				return OUT;
			}
			[domain("tri")]
			[outputcotrolpoints(3)]
			[partitioning("integer")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("ConstantsHull")]
			hsout hul(InputPatch <vertout,3> In, uint i : SV_OutputControlPointID){
				hsout OUT;
				OUT.pos = In[i].pos;
				OUT.texcoord = In[i].texcoord;
				OUT.Normal = In[i].Normal;
				return OUT;
			}
			[domain("tri")]
			dsout dom(constant_hsout In, float3 domLoc:SV_DomainLocation, const OutputPatch<hsout,3> patch){
				dsout OUT;
				float4 p;
				p.xyz = patch[0].pos * domLoc.z + patch[1].pos * domLoc.x + patch[2].pos * domLoc.y;
				p.w = 1.0;
				float3 n;
				n = normalize(patch[0].Normal * domLoc.z + patch[1].Normal * domLoc.x + patch[2].Normal * domLoc.y);
				float3 t;
				t = patch[0].texcoord * domLoc.z + patch[1].texcoord * domLoc.x + patch[2].texcoord * domLoc.y;
				float2 uv = TRANSFORM_TEX(t, _DispTex);
				float tex = tex2Dlod(_DispTex, float4(uv, 0, 0)).r;
				p.xyz += n * tex * _Displacement;
				OUT.pos = UnityObjectToClipPos(p);
				OUT.Normal = n;
				OUT.lightDir = normalize(ObjSpaceLightDir(p));
				OUT.viewDir = normalize(ObjSpaceViewDir(p));
				TRANSFER_VERTEX_TO_FRAGMENT(OUT);
				return OUT;
			}

			fixed4 frag(dsout In):COLOR{
				fixed atten = LIGHT_ATTENUATION(In);
				float diffuse = max(0, mul(In.lightDir, In.Normal));
				float specular = max(0, mul(normalize(In.viewDir + In.lightDir), In.Normal));
				specular = pow(specular, 30);
				float4 color = UNITY_LIGHTMODEL_AMBIENT + (_Diffuse * _LightColor0 * diffuse + _LightColor0 * half4(1.0,1.0,1.0,1.0) * specular) * atten;
				return color;
			}
			ENDCG
		}
	}
	FallBack "Diffuse"
}

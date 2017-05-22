﻿Shader "Custom/MyShader5-6" {
	Properties {
			_Diffuse("Diffuse Color", Color) = (1.0, 1.0, 1.0, 1.0)
			_DispTex("Disp Texture", 2D) = "gray"{}
			_Displacement("Displacement", Range(0, 0.2)) = 0.1
	} 
	SubShader {
		Tags {"RenderType"="Opaque"}
		CGPROGRAM
		#pragma surface surf Lambert addshadow fullforwardshadows vertex:vert tessellate:tess
		#include "Tessellation.cginc"

		struct appdata {
			float4 vertex : POSITION;
			float4 tangent : TANGENT;
			float3 normal : NORMAL;
			float2 texcoord : TEXCOORD0; 
		};
		
		float _Displacement;
		sampler2D _DispTex;
		float4 _DispTex_ST;
	
		float4 tess(appdata v0, appdata v1, appdata v2){
			return UnityEdgeLengthBasedTess(v0.vertex, v1.vertex, v2.vertex, 5);
		}

		void vert(inout appdata v){
			float2 uv = TRANSFORM_TEX(v.texcoord, _DispTex);
			float tex = tex2Dlod(_DispTex, float4(uv, 0, 0)).r;
			v.vertex.xyz += v.normal * tex * _Displacement;
		}

		struct Input {
			float color : COLOR;
		};

		float4 _Diffuse;

		void surf(Input IN, inout SurfaceOutput o){
			o.Albedo = _Diffuse;
		}

		ENDCG
	}
}

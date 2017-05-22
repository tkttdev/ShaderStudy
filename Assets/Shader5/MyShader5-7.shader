Shader "Custom/MyShader5-7" {
	Properties {
			_Diffuse("Diffuse Color", Color) = (1.0, 1.0, 1.0, 1.0)
			_Phong("Phong", Range(0, 0.5)) = 0
	} 
	SubShader {
		Tags {"RenderType"="Opaque"}
		CGPROGRAM
		#pragma surface surf Lambert addshadow fullforwardshadows vertex:vert tessellate:tess tessphong:_Phong
		#include "Tessellation.cginc"

		struct appdata {
			float4 vertex : POSITION;
			float3 normal : NORMAL;
			float2 texcoord : TEXCOORD0; 
		};

		void vert(inout appdata v){}
		
		float _Phong;
		float4 tess(appdata v0, appdata v1, appdata v2){
			return UnityEdgeLengthBasedTess(v0.vertex, v1.vertex, v2.vertex, 5);
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

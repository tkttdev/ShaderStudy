Shader "Custom/MyShader2-5" {
	Properties {
		_Texture("Texture", 2D) = "red"{}
		_AlphaMap("AlphaMap", 2D) = "red"{}
	}
	SubShader {
		Tags { "RenderType"="Opaque" "Queue"="Transparent" }
		
		CGPROGRAM
		
		#pragma surface surf Lambert alpha

		struct Input {
			float2 uv_Texture;
			float2 uv_AlphaMap;
		};

		sampler2D _Texture;
		sampler2D _AlphaMap;

		void surf(Input IN, inout SurfaceOutput o) {
			o.Alpha = tex2D(_AlphaMap, IN.uv_AlphaMap);
			o.Albedo = tex2D(_Texture, IN.uv_Texture).rgb*o.Alpha;
		}

		ENDCG
	}
	FallBack "Diffuse"
}

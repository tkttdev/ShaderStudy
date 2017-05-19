Shader "Custom/MyShader2-2" {
	Properties {
		_Color ("Diffuse Color", Color) = (1.0, 1.0, 1.0)
	}
	SubShader {
		Tags{"RenderType" = "Opaque"}
		CGPROGRAM
		#pragma surface surf Lambert
		struct Input {
			float4 color:COLOR;
		};
		float4 _Color;
		sampler2D _Texture;
		void surf(Input IN, inout SurfaceOutput o) {
			o.Albedo = _Color;
		}
		ENDCG
	}
	FallBack "Diffuse"
}

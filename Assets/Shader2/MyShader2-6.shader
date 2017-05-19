Shader "Custom/MyShader2-6" {
	Properties {
		_Bump("Bump", 2D) = "red"{}
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		
		CGPROGRAM
		#pragma surface surf Lambert

		struct Input {
			float2 uv_Bump;
		};

		sampler2D _Bump;

		void surf (Input IN, inout SurfaceOutput o) {
			o.Albedo = half3(1.0, 0.6, 0.4);
			o.Normal = UnpackNormal(tex2D(_Bump, IN.uv_Bump));
		}
		ENDCG
	}
	FallBack "Diffuse"
}

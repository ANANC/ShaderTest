
Shader "Custom/7.2 NormalMapWorldSpace"
{
    Properties
    {
        _Color ("Color Tint", Color) = (1,1,1,1)
        _MainTex ("Main Tex", 2D) = "white" {}
		_BumpMap("Normal Map",2D) = "bump" {}
		_BumpScale("Bump Scale",Float) = 1.0
		_Specular("Specular",Color) = (1,1,1,1)
		_Gloss("Gloss",Range(8.0,256)) = 20
	}

	SubShader
	{

		Pass{
		Tags { "LightMode" = "ForwardBase" }

		CGPROGRAM
		#pragma vertex vert
		#pragma fragment frag

		#include "Lighting.cginc"

		fixed4 _Color;
		sampler2D _MainTex;
		float4 _MainTex_ST;
		sampler2D _BumpMap;
		float4 _BumpMap_ST;
		float _BumpScale;
		fixed4 _Specular;
		float _Gloss;

		struct a2v {
			float4 vertex :POSITION;
			float3 normal :NORMAL; //法线
			float4 tangent:TANGENT;//切线
			float4 texcoord:TEXCOORD0;
		};

		struct v2f {
			float4 pos:SV_POSITION;
			float4 uv:TEXCOORD0;
			float4 TtoW0:TEXCOORD1;
			float4 TtoW1:TEXCOORD2;
			float4 TtoW2:TEXCOORD3;
		};


		v2f vert(a2v v) {
			v2f o;
			o.pos = UnityObjectToClipPos(v.vertex);

			o.uv.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
			o.uv.zw = v.texcoord.xy * _BumpMap_ST.xy + _BumpMap_ST.zw;

			float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
			fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);					//法线
			fixed3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);					//切线
			fixed3 worldBinormal = cross(worldNormal, worldTangent) * v.tangent.w;		//副切线

			o.TtoW0 = float4(worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x);
			o.TtoW1 = float4(worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y);
			o.TtoW2 = float4(worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z);

			return o;
		}

		fixed4 frag(v2f i) :SV_Target{
			float3 worldPos = float3(i.TtoW0.w,i.TtoW1.w,i.TtoW2.w);

			// 因为UnityWorldSpaceLightDir是从点到光源的方向。所以需要反向。
			fixed3 lightDir = -normalize(UnityWorldSpaceLightDir(worldPos));
			fixed3 viewDir = -normalize(UnityWorldSpaceViewDir(worldPos));

			fixed3 bump = UnpackNormal(tex2D(_BumpMap, i.uv.zw));	//得到法线
			bump.xy *= _BumpScale;
			bump.z = sqrt(1.0 - saturate(dot(bump.xy, bump.xy)));
			bump = normalize(half3(dot(i.TtoW0.xyz, bump), dot(i.TtoW1.xyz, bump), dot(i.TtoW2.xyz, bump)));

			//----------

			fixed3 tangentLightDir = normalize(lightDir);
			fixed3 tangentViewDir = normalize(viewDir);

			fixed4 packedNormal = tex2D(_BumpMap, i.uv.zw);
			fixed3 tangentNormal;

			tangentNormal = UnpackNormal(packedNormal);
			tangentNormal.xy *= _BumpScale;
			tangentNormal.z = sqrt(1.0 - saturate(dot(tangentNormal.xy, tangentNormal.xy)));

			fixed3 albedo = tex2D(_MainTex, i.uv).rgb * _Color.rgb; //反射
			fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo; //环境映射
			fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(tangentNormal, tangentLightDir));	//漫反射

			fixed3 halfDir = normalize(tangentLightDir + tangentViewDir);	//光照+视图角度
			fixed3 specular = _LightColor0.rbg * _Specular.rgb * pow(max(0, dot(tangentNormal, halfDir)), _Gloss);

			return fixed4(ambient + diffuse + specular, 1.0);
		}

			ENDCG
		}
    }
    FallBack "Diffuse"
}

Shader "Custom/11 WaterShader"
{
	Properties
	{

	}
	SubShader
	{
	   Pass
		{
			Tags{"LightMode" = "ShadowCaster"}	//光照类型 向前渲染

			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			float _Magnitude;
			float _Frequency;
			float _InvWaveLength;
			float _Speed;

			struct a2v {
				float4 vertex:POSITION;
				float4 vertoord:VERTOORD0;
			};

			struct v2f {
				V2F_SHADOW_CASTER;
			};

			v2f vert(a2v i)
			{
				v2f o;

				//设置偏移值
				float4 offset;

				//除了X轴其他轴不偏移
				offset.yzw = float3(0.0, 0.0, 0.0);



				return o;
			}

			ENDCG
			
		}
    }
    FallBack "Diffuse"
}

Shader "Custom/11 Water"
{
    Properties
    {
        _MainTex ("主纹理", 2D) = "white" {}
		_Color("颜色", Color) = (1,1,1,1)
		_Magnitude("扭曲力度",Float) = 1
		_Frequency("扭曲频率",Float) = 1
		_InvWaveLength("扭曲反向波浪长度",Float) = 1
		_Speed("速度",Float) = 1
	}

	SubShader
	{
		Tags
		{
			"Queue" = "Transparent"			//渲染层级 物体
			"IgnoreProjector" = "True"		//无视项目投影
			"RenderType" = "Transparent"	//渲染类型 物体
			"DisableBatching" = "True"		//不合批
		}

		Pass
		{
			Tags{"LightMode" = "ForwardBase"}

			ZWrite Off
			Blend SrcAlpha OneMinusSrcAlpha
			Cull Off

			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			sampler2D _MainTex;
			float4 _MainTex_ST;
			fixed4 _Color;
			float _Magnitude;
			float _Frequency;
			float _InvWaveLength;
			float _Speed;

			struct a2v {
				float4 vertex:POSITION;			//应用空间坐标
				float4 texcoord:TEXCOORD0;		//应用空间纹理坐标
			};

			struct v2f {
				float4 pos:SV_POSITION;			//裁剪空间坐标
				float2 uv:TEXCOORD0;			//纹理坐标
			};

			v2f vert(a2v v)
			{
				v2f o;

				// 定义偏移值
				float4 offset;

				//其他轴向不变
				offset.yzw = float3(0.0, 0.0, 0.0);

				//扭曲偏移值
				float frequencyOffset = _Frequency * _Time.y;

				//当前点波浪高度
				float3 vertexInvWaveLength = float3(v.vertex.x * _InvWaveLength, v.vertex.y * _InvWaveLength, v.vertex.z * _InvWaveLength);

				//只改变x轴
				//偏移值
				offset.x = sin(frequencyOffset+ vertexInvWaveLength.x+ vertexInvWaveLength.y+ vertexInvWaveLength.z) * _Magnitude;

				//顶点+偏移 转换成裁剪空间坐标
				o.pos = UnityObjectToClipPos(v.vertex + offset);

				//得到纹理坐标
				o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
				//纹理坐标根据时间进行偏移
				o.uv += float2(0.0, _Time.y * _Speed);

				return o;
			}

			fixed4 frag(v2f i) : SV_Target{
				//纹理采样
				fixed4 c = tex2D(_MainTex,i.uv);

				//环境光
				c.rgb *= _Color.rgb;

				return c;
			}

			ENDCG
		}
	}


    FallBack "Transparent/VertexLit"
}

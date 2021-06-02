Shader "Custom/11 ImageSequenceAnimation"
{
    Properties
    {
        _Color ("环境光颜色", Color) = (1,1,1,1)
        _MainTex ("循环纹理", 2D) = "white" {}
		_HorizontalAmount("水平方向序列帧个数",Float) = 4
		_VerticalAmount("垂直方向序列帧个数",Float) = 4
		_Speed("速度",Range(1,100)) = 30
	}
		SubShader
		{
			Tags {
				"Queue" = "Transparent"	//渲染等级 透明层
				"IgnoreProjector" = "True"	//无视项目阴影
				"RenderType" = "Transparent" //渲染类型 透明层
			}

			Pass{
				Tags = {"LightMode" = "ForwardBase"}	//光照类型 向前渲染

				ZWrite Off	//深度写入

				Blend SrcAlpha OneMinusSrcAlpha	//混合渲染

				CGPROGRAM

				#pragma vertex vert
				#pragma fragment frag

				float4 _Color;
				sampler2D _MainTex;
				float4 _MainTex_ST;
				float _HorizontalAmount;
				float _VerticalAmount;
				float _Speed;

				struct a2v {
					float4 vertex:POSITON;
					float4 texcoord:TEXCOORD0;
				};

				struct v2f {
					float4 pos : SV_POSITION;
					float2 uv:TEXCOORD0;
				};

				v2f vert(a2v v)
				{
					v2f o;

					//得到裁剪空间坐标
					o.pos = UnityObjectToClipPos(v.vertex);

					//得到纹理坐标
					o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);

					return o;
				}

				fixed4 frag(v2f f) :SV_Target{
					//_Time是Unity变量 代表从场景加载开始所经历的时间 (x = t/20, y = t, z = 2*t, w = 3*t)
					//时间 = 取整（当前总时间 * 动画速度）
					flaot time = floor(_Time.y * _Speed)

					// 水平方向的速度 = 取整（时间 / 水平方向序列帧个数）
					float row = floor(time / _HorizontalAmount);

					// 垂直方向 = 时间 - 列数 * 个数
					float column = time - row * _HorizontalAmount;

					// 基础纹理位置加上序列帧采样位置
					half2 uv = i.uv + half2(column, -row);

					//保证偏移后的位置在范围内
					uv.x /= _HorizontalAmount;
					uv.y /= _VerticalAmount;

					//纹理采样
					fixed4 c = tex2D(_MainTex, uv);

					//纹理*环境色
					c.rgb *= _Color;

					return c;
				}
		}
       
    }
    FallBack "Transparent/VertexLit"
}

using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Baking : MonoBehaviour
{
	private MeshFilter meshFilter;
	public Texture2D baked;

	void Start ()
	{
		meshFilter = GetComponentInChildren<MeshFilter>();
		baked = new Texture2D(512, 512);
		Color[] colors = new Color[baked.width*baked.height];
		for (int x = 0; x < baked.width; ++x) {
			for (int y = 0; y < baked.height; ++y) {
				int index = x + y * baked.width;
				float c = index/(float)colors.Length;
				colors[index] = new Color(c,c,c,1f);
			}
		}

		Mesh mesh = meshFilter.sharedMesh;
		Vector3[] vertices = mesh.vertices;
		Vector2[] uvs = mesh.uv;
		int[] triangles = mesh.triangles;
		int triCount = triangles.Length;
		for (int tri = 0; tri < triCount; tri += 3) {
			Vector3 vertexA = vertices[triangles[tri]];
			Vector3 vertexB = vertices[triangles[tri+1]];
			Vector3 vertexC = vertices[triangles[tri+2]];
			Vector2 uvA = uvs[triangles[tri]];
			Vector2 uvB = uvs[triangles[tri+1]];
			Vector2 uvC = uvs[triangles[tri+2]];
			int minX = (int)(Mathf.Min(uvA.x, Mathf.Min(uvB.x, uvC.x)) * baked.width);
			int maxX = (int)(Mathf.Max(uvA.x, Mathf.Max(uvB.x, uvC.x)) * baked.width);
			int minY = (int)(Mathf.Min(uvA.y, Mathf.Min(uvB.y, uvC.y)) * baked.height);
			int maxY = (int)(Mathf.Max(uvA.y, Mathf.Max(uvB.y, uvC.y)) * baked.height);
			float areaTotal = TriangleArea(uvA, uvB, uvC);
			for (int pixelX = minX; pixelX <= maxX; ++pixelX) {
				for (int pixelY = minY; pixelY <= maxY; ++pixelY) {
					Vector2 uv = new Vector2(pixelX/(float)baked.width, pixelY/(float)baked.height); 
					float areaA = TriangleArea(uv, uvB, uvC) / areaTotal;
					float areaB = TriangleArea(uv, uvA, uvC) / areaTotal;
					float areaC = TriangleArea(uv, uvA, uvB) / areaTotal;
					Vector3 vertex = Vector3.Lerp(Vector3.Lerp(Vector3.Lerp(vertexA, vertexC, areaC), vertexB, areaB), vertexA, areaA);
					int index = pixelX + pixelY * baked.width;
					colors[index] = new Color(vertex.x, vertex.y, vertex.z);
				}
			}
			// for (int vIndex = 0; vIndex < 3; ++vIndex) {
			// 	int vertexIndex = triangles[tri+vIndex];
			// 	Vector3 vertex = vertices[vertexIndex];
			// 	Vector2 uv = uvs[vertexIndex];

			// 	int index = (int)(uv.x * baked.width) + (int)(uv.y * baked.height) * baked.width;
			// 	colors[index] = new Color(vertex.x, vertex.y, vertex.z);
			// }
		}
		baked.SetPixels(colors);
		baked.Apply(false);
	}
	
	void Update ()
	{
		
	}

	void BakeNormal ()
	{

	}

	// http://stackoverflow.com/questions/10947885/calculation-the-area-of-a-triangle
	float TriangleArea (Vector2 a, Vector2 b, Vector2 c)
	{
		float valueA = a.magnitude;
		float valueB = b.magnitude;
		float valueC = c.magnitude;
		float i = (valueA + valueB + valueC) / 2f;
		return Mathf.Sqrt(i * (i - valueA) * (i - valueB) * (i - valueC));
	}

	float TriangleArea (Vector3 a, Vector3 b, Vector3 c)
	{
		return Vector3.Cross(a - b, a - c).magnitude / 2f;
	}
}

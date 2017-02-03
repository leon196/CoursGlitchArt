using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Grid : MonoBehaviour
{
	public int range = 32;
	public float size = 1f;
	public Shader shader;

	private Mesh mesh;
	private int verticesMax = 65000;
	private int width;
	private int height;
	private int depth;
	private int widthScaled;
	private int heightScaled;
	private int depthScaled;
	private Material material;

	void Start ()
	{
		width = range;
		height = range;
		depth = range;
		widthScaled = (int)(range*size);
		heightScaled = (int)(range*size);
		depthScaled = (int)(range*size);
		material = new Material(shader);

		GenerateLines();
	}
	
	void Update ()
	{
		
	}

	Vector3 GetAxis (float x, float y, int axis, bool inverse)
	{
		Vector3 value = new Vector3();
		switch (axis) {
			case 0:
			value.x = x * widthScaled - widthScaled/2f;
			value.y = y * heightScaled - heightScaled/2f;
			value.z = depthScaled/2f * (inverse ? -1f : 1f);
			break;
			case 1:
			value.x = x * widthScaled - widthScaled/2f;
			value.y = depthScaled/2f * (inverse ? -1f : 1f);
			value.z = y * heightScaled - heightScaled/2f;
			break;
			case 2:
			value.x = depthScaled/2f * (inverse ? -1f : 1f);
			value.z = x * widthScaled - widthScaled/2f;
			value.y = y * heightScaled - heightScaled/2f;
			break;
		}
		return value;
	}

	void GenerateLines ()
	{
		int vertexCount = (width*height)*2*3;
		int meshCount = 1 + (int)Mathf.Floor(vertexCount / verticesMax);
		int vertexIndex = 0;

		for (int meshIndex = 0; meshIndex < meshCount; ++meshIndex)
		{
			Mesh mesh = new Mesh();
			int count = vertexCount;
			if (meshCount > 1) {
				if (meshIndex == meshCount - 1) {
					count = vertexCount % verticesMax;
				} else {
					count = verticesMax;
				}
			}

			Vector3[] vertices = new Vector3[count];
			Vector3[] normals = new Vector3[count];
			Vector2[] uvs = new Vector2[count];
			int[] indices = new int[count];

			Vector3 a = new Vector3();
			Vector3 b = new Vector3();

			for (int i = 0; i < count-1; i += 2) 
			{
				float x = ((vertexIndex/2) % width) / (float)width;
				float y = (Mathf.Floor((vertexIndex/2) / width) % depth) / (float)height;

				int axis = (int)((vertexIndex/(float)vertexCount)*3f);
				a = GetAxis(x, y, axis, false);
				b = GetAxis(x, y, axis, true);

				vertices[i] = a;
				vertices[i+1] = b;
				uvs[i] = Vector2.zero;
				uvs[i+1] = Vector2.one;
				indices[i] = i;
				indices[i+1] = i+1;

				vertexIndex += 2;
			}

			mesh.vertices = vertices;
			mesh.normals = normals;
			mesh.uv = uvs;
			mesh.SetIndices(indices, MeshTopology.Lines, 0);

			GameObject meshGameObject = GameObject.CreatePrimitive(PrimitiveType.Cube);
			GameObject.Destroy(meshGameObject.GetComponent<Collider>());
			meshGameObject.name = "GeometryGrid";
			meshGameObject.GetComponent<MeshFilter>().mesh = mesh;
			meshGameObject.GetComponent<Renderer>().sharedMaterial = material;
			meshGameObject.transform.parent = transform;
			meshGameObject.transform.localPosition = Vector3.zero;
			meshGameObject.transform.localRotation = Quaternion.identity;
			meshGameObject.transform.localScale = Vector3.one;
			meshGameObject.layer = gameObject.layer;
		}
	}
}
